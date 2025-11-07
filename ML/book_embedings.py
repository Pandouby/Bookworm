# Install dependencies first (uncomment if needed)
# !pip install sentence-transformers numpy

from sentence_transformers import SentenceTransformer
import numpy as np

# Use a compact embedding model
model = SentenceTransformer("all-MiniLM-L6-v2")

# --- MOCK DATA ----------------------------------------------------

books = [
    {
        "title": "The Hobbit",
        "authors": ["J.R.R. Tolkien"],
        "release_year": 1937,
        "publisher": "George Allen & Unwin",
        "genres": ["Fantasy", "Adventure"],
        "isbn": "978-0261103344",
        "description": "A hobbit named Bilbo Baggins goes on a quest with dwarves to reclaim a treasure guarded by a dragon.",
        "avg_rating": 4.7,
        "rating_count": 2500000
    },
    {
        "title": "The Fellowship of the Ring",
        "authors": ["J.R.R. Tolkien"],
        "release_year": 1954,
        "publisher": "George Allen & Unwin",
        "genres": ["Fantasy", "Epic"],
        "isbn": "978-0261102354",
        "description": "A young hobbit, Frodo, begins his journey to destroy the One Ring, accompanied by a fellowship of friends.",
        "avg_rating": 4.8,
        "rating_count": 3000000
    },
    {
        "title": "A Brief History of Time",
        "authors": ["Stephen Hawking"],
        "release_year": 1988,
        "publisher": "Bantam Books",
        "genres": ["Science", "Non-fiction"],
        "isbn": "978-0553380163",
        "description": "An overview of cosmology, black holes, and the nature of the universe explained for a general audience.",
        "avg_rating": 4.5,
        "rating_count": 1200000
    }
]

# --- HELPER FUNCTIONS --------------------------------------------

def normalize(v):
    """L2 normalize a vector"""
    return v / np.linalg.norm(v)

def get_text_embedding(texts):
    """Get a single embedding for one or more strings"""
    if isinstance(texts, list):
        return np.mean(model.encode(texts), axis=0)
    else:
        return model.encode(texts)

def encode_book(book):
    """Turn a book dictionary into a numeric feature vector"""
    title_emb = get_text_embedding(book["title"])
    desc_emb = get_text_embedding(book["description"])
    author_emb = get_text_embedding(book["authors"])
    genre_emb = get_text_embedding(book["genres"])
    publisher_emb = get_text_embedding(book["publisher"])

    # Numeric features normalized
    year_norm = (book["release_year"] - 1900) / (2025 - 1900)
    rating_norm = book["avg_rating"] / 5.0
    rating_count_norm = np.log1p(book["rating_count"]) / np.log1p(1e7)  # scale down large values

    numeric_vec = np.array([year_norm, rating_norm, rating_count_norm])
    numeric_vec = np.pad(numeric_vec, (0, len(title_emb) - len(numeric_vec)))

    # Weighted combination (adjust weights to taste)
    combined = (
        0.3 * desc_emb +
        0.2 * title_emb +
        0.2 * author_emb +
        0.15 * genre_emb +
        0.1 * publisher_emb +
        0.05 * numeric_vec
    )

    return normalize(combined)

def cosine_similarity(a, b):
    return np.dot(a, b)

# --- ENCODE ALL BOOKS --------------------------------------------

vectors = {book["title"]: encode_book(book) for book in books}

# --- COMPUTE SIMILARITIES ----------------------------------------

def print_similarities(target_title):
    target_vec = vectors[target_title]
    print(f"\n📖 Similarities to '{target_title}':")
    for title, vec in vectors.items():
        if title != target_title:
            sim = cosine_similarity(target_vec, vec)
            print(f"  → {title}: {sim:.3f}")

print_similarities("The Hobbit")
print_similarities("A Brief History of Time")

# print(vectors.items())

