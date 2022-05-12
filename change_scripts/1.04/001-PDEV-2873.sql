/*
    Author: Jonathan Zacharuk
    Date:   March 14, 2022
    Story:  PDEV-2873: Vault prepare is silently failing
*/

CREATE TABLE audit.prepare_log
(
  id bigserial not null primary key,
  username text not null,  
  version text,
  start_time timestamp without time zone not null,
  finish_time timestamp without time zone not null,  
  analyze_start timestamp with time zone,
  analyze_finish timestamp with time zone,
  prepare_start timestamp with time zone,
  prepare_finish timestamp with time zone,
  counts jsonb,
  success boolean not null,
  error_code text,
  error_message text
);

CREATE OR REPLACE FUNCTION api.prepare()
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
  DECLARE v_version text := null;
  DECLARE v_analyze_start timestamptz := null;
  DECLARE v_analyze_finish timestamptz := null;
  DECLARE v_prepare_start timestamptz := null;
  DECLARE v_prepare_finish timestamptz := null;
  DECLARE v_counts jsonb := null;
BEGIN
    BEGIN
      v_version = api.version();

      v_analyze_start = clock_timestamp();
      EXECUTE admin.analyze_db();
      v_analyze_finish = clock_timestamp();

      --If the concept.prepare() function exists then execute it.
      v_prepare_start = clock_timestamp();
      IF(EXISTS(SELECT 1
                  FROM pg_proc as f
                  JOIN pg_namespace as s
                    ON s.oid = f.pronamespace
                 WHERE f.proname = 'prepare'
                   AND s.nspname = 'concept' ))
      THEN
        PERFORM concept.prepare();
      ELSE
        RAISE EXCEPTION 'Function concept.prepare does not exist';
      END IF;
      v_prepare_finish = clock_timestamp();

      -- Get a count of all materialized-views/tables in the concept/universal schemas.
      v_counts = (
        SELECT json_agg(row_counts) FROM (
          SELECT 
            n.nspname as schema_name, 
            c.relname as relation_name, 
            c.relkind as relation_kind,
            (xpath('/row/cnt/text()', query_to_xml(format('select count(*) as cnt from %I.%I', n.nspname, c.relname), false, true, '')))[1]::text::int as row_count
          FROM pg_catalog.pg_class c
          JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE c.relkind in ('r', 'm')
          AND n.nspname in ('concept', 'universal')
          ORDER BY schema_name, relation_name, relation_kind
        ) as row_counts
      );

      --Insert a row into the prepare_log table to indicate that the prepare was executed successfully.
      INSERT INTO audit.prepare_log(username, version, start_time, finish_time, analyze_start, analyze_finish, prepare_start, prepare_finish, counts, success, error_code, error_message)
      VALUES (CURRENT_USER, v_version, transaction_timestamp(), clock_timestamp(), v_analyze_start, v_analyze_finish, v_prepare_start, v_prepare_finish, v_counts, true, null, null);
      
      --Return true to indicate that the preparation succeeded.
      RETURN TRUE;

    EXCEPTION WHEN others THEN
      --Insert a row into the prepare_log table to indicate that the prepare failed to run.
      INSERT INTO audit.prepare_log(username, version, start_time, finish_time, analyze_start, analyze_finish, prepare_start, prepare_finish, counts, success, error_code, error_message)
      VALUES (CURRENT_USER, v_version, transaction_timestamp(), clock_timestamp(), v_analyze_start, v_analyze_finish, v_prepare_start, v_prepare_finish, v_counts, false, SQLSTATE, SQLERRM);

      --Pass generic warning back to the client.
      RAISE WARNING 'Error occured in api.prepare(). See audit.prepare_log.';

      --Return false to indicate that the preparation failed.
      RETURN FALSE;
    END;
  END;
$function$

