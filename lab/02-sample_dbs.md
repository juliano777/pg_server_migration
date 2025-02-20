# Building our lab - sample databases

## About the sample databases

- [pagila](https://ftp.postgresql.org/pub/projects/pgFoundry/dbsamples/pagila/pagila/pagila-0.10.1.zip)
- [french-towns-communes-francaises](https://ftp.postgresql.org/pub/projects/pgFoundry/dbsamples/french-towns-communes-francais/french-towns-communes-francaises-1.0/french-towns-communes-francaises-1.0.tar.gz)

## User and database creation

[postgres $][old-gamma] Create user and database
```bash
# SQL string to create the user for the new database
SQL="CREATE ROLE user_ftcf REPLICATION LOGIN ENCRYPTED PASSWORD '123'"

# With psql execute the statement
psql -c "${SQL}"

# SQL string to create the new database and the new user as its owner
SQL='CREATE DATABASE db_ftcf OWNER user_ftcf'

# With psql execute the statement
psql -c "${SQL}"
```

## Populating the new database

[postgres $][old-gamma] OS shell commands to populate the database
```bash
# URL for the new database
URL="https://ftp.postgresql.org/pub/projects/pgFoundry/dbsamples/\
french-towns-communes-francais/french-towns-communes-francaises-1.0/\
french-towns-communes-francaises-1.0.tar.gz"

# String for the file name
F=`basename "${URL}"`

# Create a new directory
mkdir /tmp/db

# Download the file
wget -c --quiet -cP /tmp/db/ ${URL}

# Get de directory
D=`tar xvf /tmp/db/${F} -C /tmp/db/ | \
    grep -E '.sql$' | \
    head -1 | \
    xargs -i dirname /tmp/db/{}`

# Execute the SQL scripts
psql -U user_ftcf -d db_ftcf -f ${D}/*.sql
```

[postgres $][old-gamma] Connect to the database via psql
```bash
psql -U user_ftcf db_ftcf
```



[>][old-gamma] Create a publication

```sql 
CREATE PUBLICATION pub_ftcf
    FOR TABLE
        public.departments,
        public.regions,
        public.towns;
```

[postgres $][old-alpha] Create an user for the new database  
```bash
# SQL string to create the user for the new database
SQL=("CREATE ROLE user_ftcf
LOGIN
ENCRYPTED PASSWORD '123'
IN ROLE pg_create_subscription
")

# With psql execute the statement
psql -c "${SQL}"

# SQL string to create the new database and the new user as its owner
SQL='CREATE DATABASE db_ftcf OWNER user_ftcf'

# With psql execute the statement
psql -c "${SQL}"
```

[postgres $][old-alpha] blablabla  
```bash
 cat << EOF > ~/.pgpass && chmod 0600 ~/.pgpass
#hostname:port:database:username:password
old-gamma.my-domain.local:5432:db_ftcf:user_ftcf:123
old-gamma:5432:db_ftcf:user_ftcf:123
localhost:5432:db_ftcf:user_ftcf:123
EOF
```

[postgres $][old-alpha] String connection to old-gamma 
```bash
DBCONN=("\
host=old-gamma \
port=5432 \
dbname=db_ftcf \
user=user_ftcf \
")
```


[postgres $][old-alpha] Create tables from a dump directly from old-gamma
```bash
pg_dump --no-comments -O -x -d -s \
    -d "${DBCONN}" \
    -t public.departments \
    -t public.regions -t public.towns | psql -U user_ftcf db_ftcf
```


[postgres $][old-alpha] blablabla  
```bash
psql -d db_ftcf -qc "
CREATE SUBSCRIPTION sub_ftcf
    CONNECTION '${DBCONN}'
    PUBLICATION pub_ftcf
    WITH (
        create_slot = true,
        slot_name = 'sub_ftcf_old_alpha'
    )
"
```

[postgres $][old-beta] Blablabla
```bash

```












function get_publication_tables(){
    SQL="
    SELECT
        schemaname||'.'||tablename
    FROM pg_publication_tables
    WHERE pubname = '${1}';"

    psql -h ${1} -d ${2} -U user_ftcf  -Atqc 
}







psql -h old-gamma -U user_ftcf -d db_ftcf -Atqc "SELECT schemaname||'.'||tablename FROM pg_publication_tables WHERE pubname = 'pub_ftcf';"


SELECT
    schemaname||'.'||tablename
FROM pg_publication_tables
WHERE pubname = 'pub_ftcf';



```sql
SELECT
    nsp_seq.nspname AS sequence_schema,
    seq.relname AS sequence_name
FROM pg_depend dep
INNER JOIN pg_class tbl
    ON (tbl.oid = dep.refobjid)
INNER JOIN pg_class seq
    ON (seq.oid = dep.objid)
INNER JOIN pg_namespace nsp_tbl
    ON (nsp_tbl.oid = tbl.relnamespace)
INNER JOIN pg_namespace nsp_seq
    ON (nsp_seq.oid = seq.relnamespace)
WHERE
    tbl.relname = 'tb_test'
    AND nsp_tbl.nspname = 'public'
    AND dep.refclassid = 'pg_class'::regclass
    AND dep.classid = 'pg_class'::regclass
    AND dep.objid != dep.refobjid;
```




```sql
CREATE OR REPLACE FUNCTION fn_tmp_get_publication_tables (
    IN pub_name text)
RETURNS TABLE (    
    pub_table text
) AS
$body$
BEGIN

RETURN QUERY
SELECT
    schemaname||'.'||tablename    
FROM pg_publication_tables
WHERE pubname = pub_name;

END;
$body$
LANGUAGE PLPGSQL;
```

```sql
CREATE OR REPLACE FUNCTION fn_tmp_get_publication_sequences (
    IN pub_name text)
RETURNS TABLE (    
    seq text
) AS
$body$
BEGIN

RETURN QUERY
SELECT
    nsp_seq.nspname||'.'||seq.relname AS seq
FROM pg_depend dep
INNER JOIN pg_class tbl
    ON (tbl.oid = dep.refobjid)
INNER JOIN pg_class seq
    ON (seq.oid = dep.objid)
INNER JOIN pg_namespace nsp_tbl
    ON (nsp_tbl.oid = tbl.relnamespace)
INNER JOIN pg_namespace nsp_seq
    ON (nsp_seq.oid = seq.relnamespace)
WHERE
    nsp_tbl.nspname||'.'||tbl.relname
        IN (SELECT fn_tmp_get_publication_tables (pub_name))
    AND dep.refclassid = 'pg_class'::regclass
    AND dep.classid = 'pg_class'::regclass
    AND dep.objid != dep.refobjid;

END;
$body$
LANGUAGE PLPGSQL;
```


```sql
CREATE OR REPLACE FUNCTION fn_tmp_get_last_seq_value (
    IN pub_name text)
RETURNS TABLE (    
    seq text,
    last_seq_value int8
) AS
$body$
BEGIN

RETURN QUERY
SELECT
    schemaname||'.'||sequencename,
    last_value
FROM pg_sequences
WHERE schemaname||'.'||sequencename
    IN (SELECT fn_tmp_get_publication_sequences(pub_name));

END;
$body$
LANGUAGE PLPGSQL;
```


