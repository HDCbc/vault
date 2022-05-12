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