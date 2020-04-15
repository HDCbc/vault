# vault
The database for the new HDC endpoint. Includes the universal schema and concept mapping.

## Development

The simplest way of creating the database is through Docker.

`docker run \
 --name vault \
 -e POSTGRES_PASSWORD=postgres_pw \
 -e TALLY_PASSWORD=tally_pw \
 -e ADAPTER_PASSWORD=adapter_pw \
 -p5432:5432 \
 hdcbc/vault:develop`
