#!/bin/bash

# Apply environment variables and other definitions
source /vagrant/sh/env.sh

# Change archive_mode to "always"
sed 's/archive_mode = on/archive_mode = always/g' \
    -i ${PGCONFDIR}/conf.d/00-provision.conf

# Create pgpass file
cat /vagrant/files/04-.pgpass > ~/.pgpass && chmod 0600 ~/.pgpass

# Stop Postgres service
sudo systemctl stop postgresql

# Remove data directory
rm -fr ${PGDATA}

# String for DB connection
DBCONN='host=old-alpha dbname=postgres user=user_rep'

# pg_basebackup from primary server
pg_basebackup \
    -D ${PGDATA} \
    -CS rs_old_beta \
    -c fast \
    -Fp -Xs -P -R -d "${DBCONN}"

# Disabling autovacuum for standby node
echo 'autovacuum = off' >> ${PGCONFDIR}/conf.d/01-rep.conf

# Add a new configuration regarding Barman backup
MSG="archive_command = 'barman-wal-archive barman00 `hostname -s` %p'"
echo "${MSG}" > ${PGCONFDIR}/conf.d/02-barman.conf

chown -R postgres: /etc/postgresql

# Start PostgreSQL service
sudo systemctl start postgresql
