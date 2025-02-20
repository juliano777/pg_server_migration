#!/bin/bash

# Apply environment variables and other definitions
source /vagrant/sh/env.sh

# Create user and database (ftcf)
psql -f /vagrant/sql/01-db_ftcf.sql

# wal_level to logical replication
echo 'wal_level = logical' >> \
    /etc/postgresql/${PGMAJOR}/main/conf.d/00-provision.conf

# URL for the new database
URL="https://ftp.postgresql.org/pub/projects/pgFoundry/dbsamples/\
french-towns-communes-francais/french-towns-communes-francaises-1.0/\
french-towns-communes-francaises-1.0.tar.gz"

# Uncompress file to /tmp/db
D="`uncompress_file "${URL}" /tmp/db | tail -1`"

# Execute the SQL scripts
psql -U user_ftcf -d db_ftcf -f ${D}/*.sql

# Remove the directory
rm -fr /tmp/db

# Add a new configuration regarding Barman backup
MSG="archive_command = 'barman-wal-archive barman00 `hostname -s` %p'"
echo "${MSG}" > ${PGCONFDIR}/conf.d/02-barman.conf

# Restart the PostgreSQL service
sudo systemctl restart postgresql

# Add replication atribute to user_ftcf
psql -c 'ALTER ROLE user_ftcf REPLICATION'

# Create a publication
psql -U user_ftcf -d db_ftcf -f /vagrant/sql/00-gamma-publication.sql

# Barman users creation
psql -f /vagrant/sql/04-barman.sql
