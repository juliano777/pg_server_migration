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


[#] PostgreSQL installation  
```bash
apt -y install postgresql-${PGMAJOR}
```

[#] postgres OS user can start/stop/restart/reload the PostgreSQL service using
SystemD
```bash
# String to add to /etc/sudoers
PGSUDO="postgres ALL=(ALL) NOPASSWD: \
`which systemctl` start postgresql, \
`which systemctl` stop postgresql, \
`which systemctl` restart postgresql, \
`which systemctl` reload postgresql"

# 
echo -e "\n${PGSUDO}" > /etc/sudoers.d/postgres

# 
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

[$] Checking sudo with postgres user
```bash
sudo systemctl restart postgresql
```




