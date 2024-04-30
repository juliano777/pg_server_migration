## Building our lab - sample databases

[#][server-name] blablabla  

```bash
<command>
```

[pagila](https://ftp.postgresql.org/pub/projects/pgFoundry/dbsamples/pagila/pagila/pagila-0.10.1.zip)

[french-towns-communes-francaises](https://ftp.postgresql.org/pub/projects/pgFoundry/dbsamples/french-towns-communes-francais/french-towns-communes-francaises-1.0/french-towns-communes-francaises-1.0.tar.gz)

[postgres $][old-gamma] blablabla  
```bash
createuser -l -P user_ftcf
```
```
Enter password for new role: 
Enter it again: 
```


[postgres $][old-gamma] blablabla  
```bash
# 
URL="https://ftp.postgresql.org/pub/projects/pgFoundry/dbsamples/\
french-towns-communes-francais/french-towns-communes-francaises-1.0/\
french-towns-communes-francaises-1.0.tar.gz"

# 
F=`basename "${URL}"`


#
wget --quiet -cP /tmp/ ${URL}

#
D=`tar xvf /tmp/${F} -C /tmp/ | \
    grep -E '.sql$' | \
    head -1 | \
    xargs -i dirname {}`

# 
createdb -O user_ftcf db_ftcf

# 
psql -U user_ftcf -d db_ftcf -f /tmp/${D}/*.sql
```

[postgres $][old-gamma] blablabla  
```bash
psql -U user_ftcf db_ftcf
```


[>][old-gamma] blablabla  

```sql 
CREATE PUBLICATION pub_ftcf
    FOR TABLE
        public.departments,
        public.regions,
        public.towns;
```


[postgres $][old-alpha] blablabla  
```bash
 cat << EOF > ~/.pgpass && chmod 0600 ~/.pgpass
#hostname:port:database:username:password
old-gamma.my-domain.local:5432:db_ftcf:user_ftcf:123
old-gamma:5432:db_ftcf:user_ftcf:123
EOF
```

[postgres $][old-alpha] blablabla  
```bash
psql -d db_ftcf -qc "
CREATE SUBSCRIPTION sub_ftcf
  CONNECTION 'host=old-gamma
              port=5432
              dbname=db_ftcf
              user=postgres'
  PUBLICATION pub_ftcf;
"



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


