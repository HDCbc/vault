/*
    Author: Jonathan Zacharuk
    Date:   March 11, 2020
    Story:  PDEV-1102: Remove Postgres Python Package
*/

-- Modify the change function to no longer verify
CREATE OR REPLACE FUNCTION api.change(
  p_change_id bigint,
  p_statement text,
  p_signature text
)
  RETURNS boolean AS
$BODY$
  DECLARE
    v_start_time timestamp := now();
    v_last_change_id bigint := api.version();
  BEGIN
    BEGIN
      --Ensure that updates are consecutive.
      IF(p_change_id <> v_last_change_id + 1) THEN
        RAISE EXCEPTION 'Received change_id % but expected %', p_change_id, v_last_change_id + 1;
      END IF;

      --Execute the update that was provided through the p_statement parameter.
      --The privileges of api role should prevent certain statements.
      EXECUTE p_statement;

      --Insert a row into the change_log to indicate that the change was executed successfully.
      INSERT INTO audit.change_log(change_id, statement, signature, username, start_time, finish_time, success, error_code, error_message)
      VALUES (p_change_id, p_statement, p_signature, CURRENT_USER, v_start_time, now(), TRUE, NULL, NULL);

      --Return true to indicate that the change succeeded.
      RETURN TRUE;

    EXCEPTION WHEN others THEN
      --Insert a row into the change_log to indicate that the change failed.
      INSERT INTO audit.change_log(change_id, statement, signature, username, start_time, finish_time, success, error_code, error_message)
      VALUES (p_change_id, p_statement, p_signature, CURRENT_USER, v_start_time, now(), FALSE, SQLSTATE, SQLERRM);

      --Pass generic warning back to the client.
      RAISE WARNING 'Error occured in api.change(). See audit.change_log.';

      --Return false to indicate that the change failed.
      RETURN FALSE;
    END;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  SECURITY DEFINER;

-- Remove the two verify functions
DROP FUNCTION IF EXISTS admin.verify_key(text, text, text);
DROP FUNCTION IF EXISTS admin.verify_trusted(text, text);

-- Remove the table that contained the trusted key
DROP TABLE IF EXISTS admin.trusted_keys;

-- Remove the python extension
DROP EXTENSION IF EXISTS plpythonu;
