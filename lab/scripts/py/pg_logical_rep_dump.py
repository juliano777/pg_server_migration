import os
import click
import psycopg



@click.command()
@click.option('--host', default='localhost', help='PostgreSQL host')
@click.option('--port', default='5432', help='PostgreSQL port')
@click.option('--database', help='PostgreSQL database name')
@click.option('--user', help='PostgreSQL user')
@click.option('--password', help='PostgreSQL password')


def main(host, port, database, user, password):
    """
    Connect to a PostgreSQL database using psycopg library.
    """
    # Check if .pgpass file exists and if credentials are being provided
    if not (user and password) and os.path.exists(
            os.path.expanduser("~/.pgpass")):
        pgpass = open(os.path.expanduser("~/.pgpass"))
        for line in pgpass:
            parts = line.strip().split(':')
            if len(parts) == 5 and parts[0] == host and parts[1] == port \
                    and parts[2] == database and parts[3] == user:
                password = parts[4]
                break

    # Connect to the database
    try:
        conn = psycopg.connect(
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
