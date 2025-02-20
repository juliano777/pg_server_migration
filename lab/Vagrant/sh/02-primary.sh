#!/bin/bash

# Apply environment variables and other definitions
source /vagrant/sh/env.sh

# Create pgpass file
cat /vagrant/files/04-.pgpass > ~/.pgpass && chmod 0600 ~/.pgpass

# Create user and database (ftcf db)
psql -f /vagrant/sql/01-db_ftcf.sql

# GRANT pg_create_subscription role to user_ftcf
psql -c 'GRANT pg_create_subscription TO user_ftcf'

# String connection to old-gamma 
DBCONN=("\
host=old-gamma \
port=5432 \
dbname=db_ftcf \
user=user_ftcf \
")

# Create tables from a dump directly from old-gamma
pg_dump --no-comments -O -x -d -s \
    -d "${DBCONN}" \
    -t public.departments \
    -t public.regions -t public.towns | psql -U user_ftcf db_ftcf


# Create the subscription
psql -f /vagrant/sql/02-sub.sql -d db_ftcf

# Create user and database (pagila db)
psql -f /vagrant/sql/03-db_pagila.sql

#
URL="https://ftp.postgresql.org/pub/projects/pgFoundry/dbsamples/pagila/\
pagila/pagila-0.10.1.zip"


# Uncompress file to /tmp/db
D="`uncompress_file "${URL}" /tmp/db | tail -1`"

#
sed '/PROCEDURAL LANGUAGE/d' -i ${D}/pagila-schema.sql
sed 's/postgres/user_pagila/g' -i ${D}/pagila-schema.sql

#
psql -U user_pagila -d db_pagila -f ${D}/pagila-schema.sql


#
psql -d db_pagila -f ${D}/pagila-data.sql

# 
psql -Atqc "
CREATE USER user_rep
  WITH REPLICATION
  SUPERUSER
  ENCRYPTED PASSWORD '123';
"

# Barman users creation
psql -f /vagrant/sql/04-barman.sql

# Add a new configuration regarding Barman backup
MSG="archive_command = 'barman-wal-archive barman00 `hostname -s` %p'"
echo "${MSG}" > ${PGCONFDIR}/conf.d/02-barman.conf

# Restart the PostgreSQL service
sudo systemctl restart postgresql
