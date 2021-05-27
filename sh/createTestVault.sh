
#!/bin/bash
set -e

# This is a slimmed down version

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d postgres <<-EOSQL
  CREATE DATABASE vault;
  CREATE ROLE tally;
  CREATE ROLE adapter;
  CREATE ROLE api;
  CREATE ROLE postgres;
EOSQL

echo "Running: ./sql/api/schema.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/schema.sql
echo "Running: ./sql/api/functions/*.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/functions/aggregate.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/functions/change.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/functions/logImport.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/functions/prepare.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/functions/reset.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/api/functions/version.sql
echo "Running: ./sql/audit/schema.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/audit/schema.sql
echo "Running: ./sql/api/tables/*.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/audit/tables/aggregate_log.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/audit/tables/change_log.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/audit/tables/import_log.sql
echo "Running: ./sql/ext/*.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/ext/schema.sql
echo "Running: ./sql/concept/schema.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/concept/schema.sql
echo "Running: ./sql/indicator/schema.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/indicator/schema.sql
echo "Running: ./sql/universal/schema.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/schema.sql
echo "Running: ./sql/universal/tables/*.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/state.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/clinic.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/practitioner.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/patient.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/patient_practitioner.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/attribute.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/entry.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/entry_attribute.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/tables/exception.sql
echo "Running: ./sql/universal/data/*.sql"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d vault -f ./sql/universal/data/attributes.sql
