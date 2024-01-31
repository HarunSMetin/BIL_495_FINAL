from fastapi import FastAPI, HTTPException
import pandas as pd
import numpy as np
from transformers import BertTokenizer, BertModel
import torch
from sklearn.metrics.pairwise import cosine_similarity
from ai_models import Review, ReviewList, RestaurantResponse, UserPreference

app = FastAPI()
from transformers import BertTokenizer, BertModel

tokenizer = BertTokenizer.from_pretrained("bert-base-multilingual-cased")
model = BertModel.from_pretrained("bert-base-multilingual-cased")

device = torch.device("cpu")
model.to(device)


def compute_embedding(text):
    inputs = tokenizer([text], return_tensors="pt", padding=True, truncation=True)
    inputs = inputs.to(device)

    with torch.no_grad():
        outputs = model(**inputs)

    embeddings = outputs.last_hidden_state
    vector = torch.mean(embeddings, dim=1).squeeze().cpu().numpy()
    return vector


@app.post("/process_reviews/")
def process_reviews(review_list: ReviewList):
    local_restaurant_vectors = {}

    for review in review_list.reviews:
        review_text = review.review
        restaurant_name = review.place
        rating = review.rating

        if pd.isna(review_text):
            continue

        review_vector = compute_embedding(review_text)
        weighted_review_vector = review_vector * rating

        if restaurant_name in local_restaurant_vectors:
            local_restaurant_vectors[restaurant_name] += weighted_review_vector
        else:
            local_restaurant_vectors[restaurant_name] = weighted_review_vector

    for restaurant in local_restaurant_vectors:
        count = len([r for r in review_list.reviews if r.place == restaurant])
        local_restaurant_vectors[restaurant] /= count * 5

    return local_restaurant_vectors


def find_similar_places(user_preference: UserPreference, restaurant_vectors, top_n=10):
    custom_review_vector = compute_embedding(user_preference.preference)
    similarity_scores = {}

    for restaurant, vector in restaurant_vectors.items():
        similarity = cosine_similarity([custom_review_vector], [vector])[0][0]
        similarity_scores[restaurant] = float(similarity)

    sorted_similarities = sorted(
        similarity_scores.items(), key=lambda item: item[1], reverse=True
    )
    return sorted_similarities[:top_n]


@app.post("/process_and_find_similar_places/")
def process_and_find_similar_places(reviews: ReviewList, preference: UserPreference):
    restaurant_vectors = process_reviews(reviews)
    similar_places = find_similar_places(preference, restaurant_vectors)
    return [
        {"name": place, "similarity_score": score} for place, score in similar_places
    ]


@app.get("/")
def read_root():
    return {"gezBot": "AI"}
