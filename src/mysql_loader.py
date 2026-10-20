"""MySQL connection and database validation for Music Discovery."""

import os
import mysql.connector
from mysql.connector import Error


def get_connection():
    """Connect to the music_discovery database."""
    return mysql.connector.connect(
        host=os.getenv("MYSQL_HOST", "127.0.0.1"),
        port=int(os.getenv("MYSQL_PORT", "3310")),
        user=os.getenv("MYSQL_USER", "music_app"),
        password=os.environ["MYSQL_PASSWORD"],
        database=os.getenv("MYSQL_DATABASE", "music_discovery"),
    )


def validate_database():
    """Check database tables and their row counts."""
    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        print("Connected to music_discovery successfully!")

        cursor.execute("SHOW TABLES")
        tables = [row[0] for row in cursor.fetchall()]

        print(f"\nTables found: {len(tables)}")

        for table in tables:
            cursor.execute(f"SELECT COUNT(*) FROM `{table}`")
            row_count = cursor.fetchone()[0]
            print(f"- {table}: {row_count:,} rows")

    except Error as err:
        print(f"MySQL error: {err}")
        raise

    finally:
        if cursor is not None:
            cursor.close()
        if conn is not None and conn.is_connected():
            conn.close()


if __name__ == "__main__":
    validate_database()
