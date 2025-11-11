import csv

def load(csv_file_path, cur):
    with open(csv_file_path, newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile, delimiter='\t')
        for row in reader:
            print(row['id'], row['genre_name'])
            cur.execute(
                """
            INSERT INTO Genres (genre_id, genre_name)
            VALUES (%s, %s)
            ON CONFLICT (genre_id) DO NOTHING
            """,
                (row['id'], row['genre_name'])
            )