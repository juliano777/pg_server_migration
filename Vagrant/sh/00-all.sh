#!/bin/bash

# Apply environment variables and other definitions
source /vagrant/sh/env.sh

# 
echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
> /etc/apt/apt.conf.d/00keep-debs

# Update apt database
apt update

# 
mkdir -p /var/cache/apt/archives 2> /dev/null
mount --bind /vagrant/archives /var/cache/apt/archives

# 
apt install -y ${PKG}

# Install postgresql-common package
apt install -y postgresql-common

# Script to automate repository configuration
/usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y

# PostgreSQL installation
apt -y install postgresql-${PGMAJOR} barman-cli

# Create a new sudoers file for postgres user
echo -e "\n${PGSUDO}" > /etc/sudoers.d/postgres

# File permissios
chmod 0440 /etc/sudoers.d/postgres

#
cat /vagrant/files/02-postgresql.conf > ${PGCONFDIR}/conf.d/00-provision.conf

#
cat /vagrant/files/01-pg_hba.conf > ${PGHBA}

# Create a mew configuration file for standby
sed "s/CLUSTER_NAME/${CLUSTER_NAME}/g" \
    /vagrant/files/05-rep.conf > ${PGCONFDIR}/conf.d/01-rep.conf

# Adjusting file permissions
chmod 0600 ${PGCONFDIR}/conf.d/01-rep.conf

# Creating .psqlrc file
cat /vagrant/files/03-.psqlrc > ~postgres/.psqlrc

# Change the ownership of configuration directory
chown -R postgres: ~postgres /etc/postgresql

# Restart PostgreSQL service
systemctl restart postgresql

# Umount apt cache directory
umount /var/cache/apt/archives

# Remove apt configuration files to don't keep downloaded files
rm -f /etc/apt/apt.conf.d/00keep-debs

# Update /etc/hosts
cat /vagrant/files/00-hosts > /etc/hosts

#  Generate SSH key for postgres user
su - postgres -c "ssh-keygen -P '' -t rsa -f ~/.ssh/id_rsa"

#archive_mode = on
#archive_command = 'barman-wal-archive barman00 pg1 %p'