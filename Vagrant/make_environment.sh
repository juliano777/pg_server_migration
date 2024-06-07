#!/bin/bash

# Apply environment variables and other definitions
source sh/env.sh

# Clean files
rm -f ssh/* archives/* 2> /dev/null

# Remove all VMs
vagrant destroy -f

# Create new VMs acording to Vagrantfile
vagrant up

echo 'Post scripts session...'

# Add public SSH keys --------------------------------------------------------
# Barman servers
for i in ${BARMAN_SERVERS}
do
    vagrant ssh ${i} -c 'sudo /vagrant/sh/05-post_all.sh barman'
    vagrant ssh ${i} -c 'sudo /vagrant/sh/05-post_all.sh postgres'
done

# Postgres servers
for i in ${PG_SERVERS}
do
    vagrant ssh ${i} -c 'sudo /vagrant/sh/05-post_all.sh postgres'
done
# ----------------------------------------------------------------------------

# Remove all .deb files
rm -fr archives/*

