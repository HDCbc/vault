/**
 * The concept schema will contain all extensions.
 */
CREATE SCHEMA ext;

-- Install the trigram extension.
CREATE EXTENSION pg_trgm SCHEMA ext;
