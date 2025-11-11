from pymilvus import connections, db

connections.connect("default", host="127.0.0.1", port="19530")
print("✅ Connected to Milvus Standalone!")

database = db.create_database("book")