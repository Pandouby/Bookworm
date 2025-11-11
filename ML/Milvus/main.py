from pymilvus import Collection
import random

import collection as milvus_collection

if __name__ == "__main__":
    print("Begin main")

    collection = Collection(
        name=milvus_collection.collection_name,
        schema=milvus_collection.schema,
        using='default',
        shards_num=2
    )

    data = [
        [i for i in range(2000)],
        [str(i) for i in range(2000)],
        [i for i in range(10000, 12000)],
        [[random.random() for _ in range(2)] for _ in range(2000)],
        # use `default_value` for a field
        [],
        # or
        None,
        # or just omit the field
    ]

    # Once your collection is enabled with dynamic schema,
    # you can add non-existing field values.
    data.append([str("dy"*i) for i in range(2000)])

    collection = Collection("book") # Get an existing collection.
    mr = collection.insert(data)
