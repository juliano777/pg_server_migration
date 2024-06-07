#!/bin/bash

# Apply environment variables and other definitions
source /vagrant/sh/env.sh

# 
echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
> /etc/apt/apt.conf.d/00keep-debs

# Update apt database
apt update > /dev/null

# 
mkdir -p /var/cache/apt/archives 2> /dev/null
mount --bind /vagrant/archives /var/cache/apt/archives

# Installing basic packages
echo 'Installing basic packages'
apt install -y ${PKG} > /dev/null

# Installing postgresql-common package
echo 'Installing postgresql-common package'
apt install -y postgresql-common > /dev/null

# Script to automate repository configuration
/usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y > /dev/null

# PostgreSQL installation
echo 'PostgreSQL installation'
apt -y install postgresql-${PGMAJOR} barman-cli > /dev/null

# Create a new sudoers file for postgres user
echo -e "\n${PGSUDO}" > /etc/sudoers.d/postgres

# File permissios
chmod 0440 /etc/sudoers.d/postgres

# Create extra configuration file
cat /vagrant/files/02-postgresql.conf > ${PGCONFDIR}/conf.d/00-provision.conf

# pg_hba.conf
cat /vagrant/files/01-pg_hba.conf > ${PGHBA}

# Create a mew configuration file for standby
sed "s/CLUSTER_NAME/${CLUSTER_NAME}/g" \
    /vagrant/files/05-rep.conf > ${PGCONFDIR}/conf.d/01-rep.conf

# Adjusting file permissions
chmod 0600 ${PGCONFDIR}/conf.d/*

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
cp ~postgres/.ssh/id_rsa.pub /vagrant/ssh/`hostname -s`-postgres.pub
