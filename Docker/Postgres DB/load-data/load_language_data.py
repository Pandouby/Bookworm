import csv

def load(csv_file_path, cur):
    with open(csv_file_path, newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile, delimiter='\t')
        for row in reader:
            # print(row)
            print(row['Id'], row['Print_Name'], row['Inverted_Name'])
            cur.execute(
                """
            INSERT INTO Languages (language_id, print_name, inverted_name)
            VALUES (%s, %s, %s)
            ON CONFLICT (language_id) DO NOTHING
            """,
                (row['Id'], row['Print_Name'], row['Inverted_Name'])
            )
