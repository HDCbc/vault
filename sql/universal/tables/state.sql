CREATE TABLE universal.state
(
  id bigserial NOT NULL,
  record_type text NOT NULL,
  record_id bigint NOT NULL,
  state text DEFAULT 'active'::text,
  effective_date timestamp without time zone,
  emr_id text,
  emr_reference text,
  CONSTRAINT state_pkey PRIMARY KEY (id)
);

ALTER TABLE universal.state OWNER TO adapter;

CREATE INDEX idx_state_record_type_effective_date
  ON universal.state
  USING btree
  (record_type COLLATE pg_catalog."default", effective_date DESC);

CREATE INDEX idx_state_state
  ON universal.state
  USING btree
  (state COLLATE pg_catalog."default");

CREATE INDEX idx_state_record_type_record_id_emr_id 
ON universal.state 
USING btree ( 
 "record_type" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST, 
 "record_id" "pg_catalog"."int8_ops" ASC NULLS LAST, 
 "emr_id" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST 
);
