#!/bin/bash

# Apply environment variables and other definitions
source /vagrant/sh/env.sh

# Stop Postgres service
systemctl disable --now postgresql

# Remove data directory
rm -fr ${PGDATA}

# Install barman
apt install -y barman

#  Generate SSH key for barman user
su - barman -c "ssh-keygen -P '' -t rsa -f ~/.ssh/id_rsa"

# Copy the public key for a shared folder
cp ~barman/.ssh/id_rsa.pub /vagrant/ssh/barman-`hostname -s`.pub

# Create .pgpass file
cat << EOF > ~barman/.pgpass && chmod 0600 ~barman/.pgpass
# hostname:port:database:username:password
old-gamma:5432:postgres:user_barman:123
old-gamma:5432:*:user_barman_stream:123
EOF

chown barman: ~barman/.pgpass

# Postgres servers configuration for Barman
SRV='old-gamma old-alpha old-beta new-gamma new-alpha new-beta'

for i in ${SRV}; do
    sed "s/<PG>/${i}/g" /vagrant/files/06-server-backup.conf | \
        sed "s/<BARMAN>/`hostname -s`/g" > /etc/barman.d/${i}.conf
done

# Copy public SSH key
sudo cp ~barman/.ssh/id_rsa.pub /vagrant/ssh/`hostname -s`-barman.pub
