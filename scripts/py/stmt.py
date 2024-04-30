# bla bla bla
sql_get_publication_tables = """
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
"""

# bla bla bla
sql_get_publication_sequences = """
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
"""

# bla bla bla
sql_get_last_seq_value = """
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
"""
