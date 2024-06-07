#!/bin/bash

# Apply environment variables and other definitions
source /vagrant/sh/env.sh

# Create pgpass file
cat /vagrant/files/04-.pgpass > ~/.pgpass && chmod 0600 ~/.pgpass

# Stop Postgres service
sudo systemctl stop postgresql

# Remove data directory
rm -fr ${PGDATA}

# String for DB connection
DBCONN='host=old-alpha dbname=postgres user=user_rep'

# 
pg_basebackup \
    -D ${PGDATA} \
    -CS rs_old_beta \
    -c fast \
    -Fp -Xs -P -R -d "${DBCONN}"

# Disabling autovacuum for standby node
echo 'autovacuum = off' >> ${PGCONFDIR}/conf.d/01-rep.conf

# Start PostgreSQL service
sudo systemctl start postgresql
