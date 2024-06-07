# PostgreSQL major version
PGMAJOR='16'

# String to add to /etc/sudoers
PGSUDO="postgres ALL=(ALL) NOPASSWD: \
`which systemctl` start postgresql, \
`which systemctl` stop postgresql, \
`which systemctl` restart postgresql, \
`which systemctl` reload postgresql, \
`which systemctl` start postgresql@${PGMAJOR}-main.service, \
`which systemctl` stop postgresql@${PGMAJOR}-main.service, \
`which systemctl` restart postgresql@${PGMAJOR}-main.service, \
`which systemctl` reload postgresql@${PGMAJOR}-main.service
"

# PostgreSQL data directory
PGDATA="/var/lib/postgresql/${PGMAJOR}/main"

# PostgreSQL configuration directory
PGCONFDIR="/etc/postgresql/${PGMAJOR}/main"

# postgresql.conf
PGCONF="${PGCONFDIR}/postgresql.conf"

# pg_hba.conf
PGHBA="${PGCONFDIR}/pg_hba.conf"

# Packages to be installed
PKG='bash-completion debconf neovim pkg-config rsync unzip'

# Cluster name
CLUSTER_NAME="`hostname -s | tr '-' '_'`"

# Command to add the barman public keys
ADD_PUB_KEY='cat /vagrant/ssh/barman-* >> ~/.ssh/authorized_keys'

# Barman servers
BARMAN_SERVERS='barman00 barman01'

# Postgres servers
PG_SERVERS='old-gamma old-alpha old-beta new-gamma new-alpha new-beta'

# All servers
ALL_SERVERS="${BARMAN_SERVERS} ${PG_SERVERS}"

# Function
function uncompress_file () {
    # URL as first parameter
    URL="${1}"

    # Target dir to uncompress
    T_DIR="${2}"

    # String for the file name
    F=`basename "${URL}"`

    # Create a new directory
    rm -fr ${T_DIR} && mkdir ${T_DIR} 2> /dev/null

    # Download the file
    wget -c --quiet -cP ${T_DIR}/ ${URL}

    # Discover if the file is zip or tar
    if (echo ${F} | grep -E '\.zip$'); then
        unzip ${T_DIR}/${F} -d ${T_DIR} | \
            grep sql | \
            awk '{print $2}' | \
            head -1 | \
            xargs -i dirname {}

    elif (echo ${F} | grep -E '\.tar'); then
        tar xvf ${T_DIR}/${F} -C ${T_DIR}/ | \
        grep -E '.sql$' | \
        head -1 | \
        xargs -i dirname ${T_DIR}/{}
    else
        echo 'ERROR: Format not supported!'
        exit 1
    fi   
}

# 
function known_hosts (){
    # Catch all hostnames and IPs from /etc/hosts
    HOSTS="`cat /etc/hosts | grep -vE '^$|^#' | tr ' ' '\n'`"

    # Add all results as know hosts
    for i in "${HOSTS}"; do
        ssh-keyscan -H ${i} >> ~/.ssh/known_hosts
    done
}


