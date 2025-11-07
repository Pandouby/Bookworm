import csv

path = "/Volumes/Extreme SSD/Book Data/bookData.txt"

with open(path, "r", encoding="utf-8") as f:
    reader = csv.DictReader(f, delimiter="\t")
    print("Column names:", reader.fieldnames)


with open(path, "r", encoding="utf-8") as f:
    reader = csv.DictReader(f, delimiter="\t")  # tab-separated
    for row in reader:
        # row is a dictionary: keys = column headers
        print(row["name"])
