/*
    Author: Jonathan Zacharuk
    Date:   March 11, 2020
    Story:  PDEV-1098: Add Observation Trigram Indexes
*/

CREATE SCHEMA IF NOT EXISTS ext;
CREATE EXTENSION IF NOT EXISTS pg_trgm SCHEMA ext;
GRANT USAGE ON SCHEMA ext TO api;
