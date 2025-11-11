# Bookworm

Bookworm is tought to be an app in which one can easily add and keep track of the books one owns and has read. It is possible to add ratings and keep track of notes and thoughts one may have on a certain book. It is possible to add a book by scaning is bar code. The idea of the Platform is to be able to take the ratings of a User and recommend similar books to ones the User has rated positivly, using an Multidimensional Embeding Space.

# Run
## Milvus Vector Databse
Go to ```/Docker/Milvus DB```\
This starts a Milvus Standalone Vector Database for testing.
```bash
docker compose up -d
```
Go to ```/ML/Milvus```\
This handels the connection to the Vector Database.
```bash
python main.py
```

## PostgreSQL Database
Go to ```/Docker/Postres DB```\
This starts a Postgres Database for local testing.
```bash
docker compose up -d
```
Go to ```/Docker/Postres DB/load-data```\
This loads the data into the Database.
```bash
python main.py
```
