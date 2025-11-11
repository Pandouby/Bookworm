import json


def load(csv_file_path, cur, conn):
    with open(csv_file_path, "r", encoding="utf-8") as reader:
        for line_num, row in enumerate(reader, start=1):
            try:
                # Not Wokring
                # Name for some is to long > 255 chars
                # Check for lenth and shorten if needed

                json_part = row.strip().split('\t')[-1]
                data = json.loads(json_part)
                key = data.get("key")
                name = data.get("name")
                birth_date = data.get("birth_date", None)
                death_date = data.get("death_date", None)
                wikipedia = data.get("wikipedia", None)

                if name is None:
                    name = ""  # or continue, depending on your logic
                elif len(name) > 255:
                    print("too long: ", name)
                    # name = name[:255]
                
                if key and name:
                    '''
                    cur.execute(
                        """
                        INSERT INTO Authors (author_key, author_name, birth_date, death_date, wikipedia)
                        VALUES (%s, %s, %s, %s, %s)
                        ON CONFLICT (author_key) DO NOTHING
                        """,
                        (key, name, birth_date, death_date, wikipedia)
                    )
                    '''
            except json.JSONDecodeError:
                continue
            if line_num % 100000 == 0:
                conn.commit()  # commit in batches
