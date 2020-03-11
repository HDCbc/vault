/*
    Author: Jonathan Zacharuk
    Date:   March 11, 2020
    Story:  PDEV-1104: Add Indices for Intrahealth Adapter
*/

CREATE INDEX IF NOT EXISTS idx_entry_attribute_emr_id_attribute_id_emr_effective_date
  ON universal.entry_attribute
  USING btree
  (emr_id, attribute_id, emr_effective_date desc);

CREATE INDEX IF NOT EXISTS idx_state_record_type_record_id_emr_id_effective_date
  ON universal.state
  USING btree
  (record_type, record_id, emr_id, effective_date desc);
