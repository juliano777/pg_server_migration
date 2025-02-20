#!/bin/bash

# Apply environment variables and other definitions
source /vagrant/sh/env.sh

# First parameter as user name
USERNAME="${1}"

# 
su - ${USERNAME} -c "${ADD_PUB_KEY}"

#
su - ${USERNAME} -c 'source /vagrant/sh/env.sh && known_hosts'