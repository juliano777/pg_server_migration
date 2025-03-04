# Preparation

Preparatory procedures for all Postgres servers.




## DNS

[#] Server names on /etc/hosts

```bash
cat << EOF >> /etc/hosts

# Old servers
192.168.56.13 old-gamma.my-domain old-gamma
192.168.56.11 old-alpha.my-domain old-alpha
192.168.56.12 old-beta.my-domain old-beta

# New servers
192.168.56.23 new-gamma.my-domain new-gamma
192.168.56.21 new-alpha.my-domain new-alpha
192.168.56.22 new-beta.my-domain new-beta
EOF
```

## PostgreSQL installation

[#] Automated repository configuration

```bash
# Install postgresql-common package
apt install -y postgresql-common

# Script to automate repository configuration
/usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
```
```
This script will enable the PostgreSQL APT repository on apt.postgresql.org on
your system. The distribution codename used will be bookworm-pgdg.

Press Enter to continue, or Ctrl-C to abort.
```
Just press Enter.  
  
  
[#] Variable for PostgreSQL major version  
```bash
read -p 'Enter the majority version of Postgres to be installed: ' PGMAJOR
```

> **Note:**
> Have in mind that the Postgres major versions for old and new servers will
> be different. Of course, the new ones will have a more current version than
> the old ones.


[#] PostgreSQL installation  
```bash
apt -y install postgresql-${PGMAJOR}
```

## Postgres post installation

[#] postgres OS user can start/stop/restart/reload the PostgreSQL service using
SystemD
```bash
# String to add to /etc/sudoers
PGSUDO="postgres ALL=(ALL) NOPASSWD: \
`which systemctl` start postgresql, \
`which systemctl` stop postgresql, \
`which systemctl` restart postgresql, \
`which systemctl` reload postgresql, \
`which systemctl` start postgresql@${PGMAJOR}-main.service, \
`which systemctl` stop postgresql@${PGMAJOR}-main.service, \
`which systemctl` restart postgresql@${PGMAJOR}-main.service, \
`which systemctl` reload postgresql@${PGMAJOR}-main.service"

# Add the new string to the sudoers file
echo -e "\n${PGSUDO}" > /etc/sudoers.d/postgres

# Adjusting the permissions
chmod 0440 /etc/sudoers.d/postgres

# Check if the new file has its syntax OK
visudo -c
```
```
/etc/sudoers: parsed OK
/etc/sudoers.d/README: parsed OK
/etc/sudoers.d/postgres: parsed OK
```
All checks must me OK.  
If not check the reason and fix it.

[postgres $][all] Checking sudo with postgres user
```bash
sudo systemctl restart postgresql
```
