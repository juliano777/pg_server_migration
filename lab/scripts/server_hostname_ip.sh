#!/bin/bash

NETMASK="${2:-24}"
SERVERS="${1:-servers.txt}"

if [ -f "${SERVERS}" ]; then
    grep -vE '^\s*$' "${SERVERS}" > /tmp/tmp_servers.txt
    mapfile -t SERVERS < /tmp/tmp_servers.txt
    rm -f /tmp/tmp_servers.txt
else
    MSG='Error! Server list file not found!'
    echo "${MSG}"
    exit 1
fi


# Function to change the hostname and IP permanently
change_server() {
    # Parameters
    # $1 = New hostname
    # $2 = New IP
    # $3 = Interface file

    hostnamectl set-hostname "${1}.my-domain.local"

    # Update the network configuration file
    sed "s:address.*:address ${2}/${NETMASK}:g" -i ${3}

    echo 'Hostname changed to: '"${1}"
    echo 'IP changed to: '"${2}"
}

# Network interface file
IF_FILE='/etc/network/interfaces.d/enp0s8'

# Display the menu using select
echo 'Choose a server to change the hostname and IP:'
select SERVER_OPTION in "${SERVERS[@]}"; do
    if [ -n "${SERVER_OPTION}" ]; then        
        SERVER_NAME=`echo "${SERVER_OPTION}" | awk '{print $1}'`
        SERVER_IP=`echo "${SERVER_OPTION}" | awk '{print $2}'`
                
        # Call the function to change the hostname and IP permanently
        change_server "${SERVER_NAME}" "${SERVER_IP}" "${IF_FILE}"
        break
    else
        echo 'Invalid option. Please select a valid server.'
    fi
done
