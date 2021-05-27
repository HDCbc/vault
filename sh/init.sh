#!/bin/bash
set -e

# The tally role will be used by the Tally application to login to the database and perform the
# updates (concepts & indicators) and aggregate queries.
# The adapter role will be used by the EMR Adapter to login to the database and perform the
# transfer of data from the EMR to the Vault.
# Note that the tally/adapter roles are created here rather than in presetup.sql so we can pass
# through the TALLY_PASSWORD and ADAPTER_PASSWORD env variables.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d postgres <<-EOSQL
  CREATE DATABASE vault;
  CREATE ROLE tally WITH LOGIN ENCRYPTED PASSWORD '$TALLY_PASSWORD';
  CREATE ROLE adapter WITH LOGIN ENCRYPTED PASSWORD '$ADAPTER_PASSWORD';
EOSQL

# Drop the default postgres database. This step is debatable as client applications may default
# to connect to this database; however, we control the clients so should not be an issue. And
# then it is just one less object we have to manage.
# psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault <<-EOSQL
#   DROP DATABASE postgres;
# EOSQL

# Run all of the sql scripts in specific order to create the schemas, tables, functions, etc.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/presetup.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/admin/schema.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/admin/functions/analyze_db.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/schema.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/functions/aggregate.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/functions/change.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/functions/logImport.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/functions/prepare.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/functions/reset.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/functions/version.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/audit/schema.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/audit/tables/aggregate_log.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/audit/tables/change_log.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/audit/tables/import_log.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/concept/schema.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/ext/schema.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/indicator/schema.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/schema.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/state.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/clinic.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/practitioner.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/patient.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/patient_practitioner.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/attribute.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/entry.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/entry_attribute.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/exception.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/data/attributes.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/postsetup.sql
