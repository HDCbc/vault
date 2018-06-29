CREATE TABLE universal.clinic
(
  id bigserial NOT NULL,
  name text NOT NULL,
  hdc_reference text NOT NULL,
  emr_id text,
  emr_reference text,
  emr text,
  CONSTRAINT clinic_pkey PRIMARY KEY (id)
);

ALTER TABLE universal.clinic OWNER TO adapter;
