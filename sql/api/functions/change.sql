/*
 * Used to change indicators and concepts. This includes creating/updating/deleting
 * indicators, creating/updating/deleting concept functions/mappings/views.
 *
 * p_change_id: The id of the change. Changes must be made in consecutive order (e.g. 1, 2, 3).
 * This is required.
 *
 * p_statement: The INSERT/UPDATE/CREATE statement to execute against the concept/indicator schema.
 * This is required.
 *
 * p_signature: An armored ASCII signature that will be used to verify the authenticity of the
 * statement. The signature will be verified against the p_statement and the public key. *TODO*
 * This is required.
 *
 * Returns true on success or false on error.
 *
 * Regardless of success or failure, a row will be inserted into the audit.change_log table.
 */
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

ALTER FUNCTION api.change(bigint, text, text)
  OWNER TO api;
