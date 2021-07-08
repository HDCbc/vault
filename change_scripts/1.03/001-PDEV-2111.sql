/*
    Author: Jonathan Zacharuk
    Date:   May 19, 2020
    Story:  PDEV-2111: Vault - Add Exception table
*/

CREATE TABLE universal.exception
(
  id bigserial NOT NULL,
  source text NOT NULL,
  record_type text NOT NULL,
  record_id bigint NULL,
  record_emr_id text NOT NULL,
  exception_type text NOT NULL,
  exception_timestamp timestamp WITH TIME zone default (now() at time zone 'utc'),
  data jsonb NOT NULL,
  CONSTRAINT exception_pkey PRIMARY KEY (id)
);

ALTER TABLE universal.exception OWNER TO adapter;