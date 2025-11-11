import psycopg2
from psycopg2 import sql

import load_language_data, load_genre_data, load_author_data

# Connection parameters (from your docker-compose)
DB_HOST = "localhost"
DB_PORT = 5432
DB_NAME = "book_db"
DB_USER = "admin"
DB_PASS = "1234"

# Connect to PostgreSQL
conn = psycopg2.connect(
    host=DB_HOST,
    port=DB_PORT,
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASS
)

# Create a cursor
cur = conn.cursor()

# Load language data into DB
# load_language_data.load("/Volumes/Extreme SSD/Book Data/iso-639-3_Name_Index.tab.txt", cur)

# Load genre data into DB
# load_genre_data.load("/Volumes/Extreme SSD/Book Data/genres.txt", cur)

# Load author data into DB
load_author_data.load("/Volumes/Extreme SSD/Book Data/ol_dump_authors_latest.txt", cur, conn)

# Commit the transaction
conn.commit()

# Close cursor and connection
cur.close()
conn.close()

print("Data inserted successfully!")
