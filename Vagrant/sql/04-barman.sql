-- Create the barman superuser
CREATE ROLE user_barman
    LOGIN
    SUPERUSER
    PASSWORD '123'
    IN ROLE pg_checkpoint, pg_read_all_settings, pg_read_all_stats;


-- Create a user that can open a replication connection
CREATE USER user_barman_stream
    REPLICATION
    PASSWORD '123';


-- 
GRANT EXECUTE ON FUNCTION pg_switch_wal() to user_barman;
GRANT EXECUTE ON FUNCTION pg_create_restore_point(text) to user_barman;
GRANT EXECUTE ON FUNCTION pg_backup_start(text, boolean) to user_barman;
GRANT EXECUTE ON FUNCTION pg_backup_stop(boolean) to user_barman;

