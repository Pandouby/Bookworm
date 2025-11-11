import json
import json
import sqlite3
import json

file_path = "/Volumes/Extreme SSD/Book Data/"

# Generate DB for Authors
'''
def build_author_db(authors_file, db_file="authors.db"):
    conn = sqlite3.connect(db_file)
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS authors (key TEXT PRIMARY KEY, name TEXT)")
    conn.commit()

    with open(authors_file, "r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, start=1):
            try:
                json_part = line.strip().split('\t')[-1]
                data = json.loads(json_part)
                key = data.get("key")
                name = data.get("name")
                if key and name:
                    cur.execute("INSERT OR REPLACE INTO authors (key, name) VALUES (?, ?)", (key, name))
            except json.JSONDecodeError:
                continue
            if line_num % 100000 == 0:
                conn.commit()  # commit in batches
    conn.commit()
    conn.close()
'''

# Get Authorname by author key form MySql Lite DB
def get_author_name(author_key, db_file="authors.db"):
    conn = sqlite3.connect(db_file)
    cur = conn.cursor()
    cur.execute("SELECT name FROM authors WHERE key = ?", (author_key,))
    result = cur.fetchone()
    conn.close()
    return result[0] if result else None

def enrich_books_with_authors(books_file, db_file="authors.db"):
    conn = sqlite3.connect(db_file)
    cur = conn.cursor()

    with open(file_path + books_file, "r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, start=1):
            try:
                # Split line if your works file has prefixes before the JSON
                parts = line.split("\t")
                json_str = parts[-1].strip()
                book = json.loads(json_str)

                # Extract author keys
                author_refs = book.get("authors", [])
                author_names = []

                for ref in author_refs:
                    # Depending on format, get actual author key
                    if isinstance(ref, dict) and "author" in ref:
                        key = ref["author"]["key"]
                    elif isinstance(ref, str):
                        key = ref
                    else:
                        continue

                    cur.execute(
                        "SELECT name FROM authors WHERE key = ?", (key,))
                    result = cur.fetchone()
                    if result:
                        author_names.append(result[0])

                book["author_names"] = author_names

                # Print progress every 1000 books
                if line_num % 1000 == 0:
                    print(f"Processed {line_num} books")

                print(book)

            except json.JSONDecodeError:
                continue
            except Exception as e:
                print(f"Error on line {line_num}: {e}")
                continue

    conn.close()
# build_author_db(file_path + "authorData.txt")

enrich_books_with_authors("workData.txt")

'''
for book in enrich_books_with_authors("workData.txt", author_lookup):
    print(book["title"], "by", ", ".join(book["author_names"]))
'''
