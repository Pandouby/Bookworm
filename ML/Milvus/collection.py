from pymilvus import CollectionSchema, FieldSchema, DataType

book_isbn = FieldSchema(
  name="book_isbn",
  dtype=DataType.INT64,
  is_primary=True,
)
book_name = FieldSchema(
  name="book_name",
  dtype=DataType.VARCHAR,
  max_length=200,
  # The default value will be used if this field is left empty during data inserts or upserts.
  # The data type of `default_value` must be the same as that specified in `dtype`.
  default_value="Unknown"
)
word_count = FieldSchema(
  name="word_count",
  dtype=DataType.INT64,
  # The default value will be used if this field is left empty during data inserts or upserts.
  # The data type of `default_value` must be the same as that specified in `dtype`.
  default_value=9999
)
book_intro = FieldSchema(
  name="book_intro",
  dtype=DataType.FLOAT_VECTOR,
  dim=1600
)
schema = CollectionSchema(
  fields=[book_isbn, book_name, word_count, book_intro],
  description="Test book search",
  enable_dynamic_field=True
)
collection_name = "book"