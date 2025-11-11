from sentence_transformers import SentenceTransformer, util

model = SentenceTransformer('all-MiniLM-L6-v2')

authors_a = ["Fiction", "Fantasy", "Horror"]
authors_b = ["Fantasy", "Romance", "Thriller"]

emb_a = model.encode(authors_a)
emb_b = model.encode(authors_b)

cosine_sim = util.cos_sim(emb_a.mean(axis=0), emb_b.mean(axis=0))
print(cosine_sim.item())