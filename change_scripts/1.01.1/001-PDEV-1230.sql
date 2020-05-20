/*
    Author: Jonathan Zacharuk
    Date:   April 24, 2020
    Story:  PDEV-1230: Vault - Clinic level aggregates failing
*/

CREATE OR REPLACE FUNCTION api.aggregate(
  IN p_indicator text,
  IN p_clinic text,
  IN p_provider text,
  IN p_effective_date date
)
  RETURNS TABLE(numerator integer, denominator integer, kount integer) AS
$BODY$
  DECLARE
    v_start_time timestamp := now();
    v_numerator_array int[];
    v_denominator_array int[];
    v_count_array int[];
    v_numerator int;
    v_denominator int;
    v_count int;
  BEGIN
    BEGIN
      --Simple prevention of SQL injection through p_indicator parameter.
      IF(p_indicator !~ '^[a-zA-Z0-9_]*$') THEN
          RAISE EXCEPTION 'Parameter p_indicator can only contains alphanumeric and underscore';
      END IF;

      --Further whitelist p_indicator to be a function that actually exists in the indicator schema.
      IF(NOT EXISTS(SELECT 1
                      FROM pg_proc as f
                      JOIN pg_namespace as s
                        ON s.oid = f.pronamespace
                     WHERE f.proname = p_indicator
                       AND s.nspname = 'indicator' )) THEN
          RAISE EXCEPTION 'Indicator function % does not exist', p_indicator;
      END IF;

      -- Ensure that the clinic reference exists. If it does not then throw an error.
      IF(NOT EXISTS(SELECT 1
                      FROM universal.clinic
                     WHERE hdc_reference = p_clinic)) THEN
          RAISE EXCEPTION 'Clinic reference "%" not found', p_clinic;
      END IF;

      -- Ensure that the provider identifier exists (if this is a provider level query). If it does not then throw an error.
      IF(p_provider IS NOT NULL AND NOT EXISTS(SELECT 1
                      FROM universal.practitioner
                     WHERE identifier = p_provider)) THEN
          RAISE EXCEPTION 'Provider identifier "%" not found', p_provider;
      END IF;

      --Execute the indicator function and store the array results returned.
      --Note possibility of SQL Injection through p_indicator here.
      EXECUTE format('SELECT * FROM indicator.%s(p_clinic_reference:=$1, p_practitioner_msp:=$2, p_effective_date:=$3)', p_indicator)
      INTO v_numerator_array, v_denominator_array, v_count_array
      USING p_clinic, p_provider, p_effective_date;

      --Count the items in each array returned from indicator function.
      -- Note that array_length(array[], 1) == NULL.
      v_numerator =
      CASE
        WHEN v_numerator_array IS NULL
        THEN NULL
        ELSE COALESCE(array_length(v_numerator_array, 1), 0)
      END;

      v_denominator =
      CASE
        WHEN v_denominator_array IS NULL
        THEN NULL
        ELSE COALESCE(array_length(v_denominator_array, 1), 0)
      END;

      v_count =
      CASE
        WHEN v_count_array IS NULL
        THEN NULL
        ELSE COALESCE(array_length(v_count_array, 1), 0)
      END;

      --Insert a row into the aggregate_log table to indicate that the aggregate query was executed successfully.
      INSERT INTO audit.aggregate_log(indicator, clinic, provider, effective_date, username, start_time, finish_time, success, numerator, denominator, kount, error_code, error_message)
      VALUES (p_indicator, p_clinic, p_provider, p_effective_date, CURRENT_USER, v_start_time, now(), TRUE, v_numerator, v_denominator, v_count, NULL, NULL);

      --Return the aggregate data.
      RETURN QUERY SELECT v_numerator as numerator, v_denominator as denominator, v_count as kount;

    EXCEPTION WHEN others THEN

      --Insert a row into the aggregate_log table to indicate that the query failed to execute.
      INSERT INTO audit.aggregate_log(indicator, clinic, provider, effective_date, username, start_time, finish_time, success, numerator, denominator, kount, error_code, error_message)
      VALUES (p_indicator, p_clinic, p_provider, p_effective_date, CURRENT_USER, v_start_time, now(), FALSE, NULL, NULL, NULL, SQLSTATE, SQLERRM);

      --Pass generic error information back to the client.
      RAISE WARNING 'Error occured in api.aggregate(). See audit.aggregate_log.';
    END;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  SECURITY DEFINER;
