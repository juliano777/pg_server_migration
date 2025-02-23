# Imports ====================================================================

from os import path as os_path

from click import command as click_cmd
from click import option as click_opt
from psycopg import connect as pg_connect

# Parameters
@click_cmd()
@click_opt('--host', default='localhost', help='PostgreSQL host')
@click_opt('--port', default='5432', help='PostgreSQL port')
@click_opt('--database', help='PostgreSQL database name')
@click_opt('--user', help='PostgreSQL user')
@click_opt('--password', help='PostgreSQL password')


def main(host, port, database, user, password):
    """
    Connect to a PostgreSQL database using psycopg library.
    """
    # Check if .pgpass file exists and if credentials are being provided
    if not (user and password) and os_path.exists(
            os_path.expanduser("~/.pgpass")):
        pgpass = open(os_path.expanduser("~/.pgpass"))
        for line in pgpass:
            parts = line.strip().split(':')
            if len(parts) == 5 and parts[0] == host and parts[1] == port \
                    and parts[2] == database and parts[3] == user:
                password = parts[4]
                break

    # Connect to the database
    try:
        conn = pg_connect(
            host=host,
            port=port,
            dbname=database,
            user=user,
            password=password
        )
        click.echo("Connection successful!")
    except Exception as e:
        click.echo(f"Error connecting to the database: {e}")
        return

if __name__ == '__main__':
    main()
