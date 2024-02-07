from pydantic import BaseModel, Field
from typing import List


class Review(BaseModel):
    place: str
    rating: float
    review: str


class ReviewList(BaseModel):
    data: List[Review]


class RestaurantResponse(BaseModel):
    name: str
    similarity_score: float


class UserPreference(BaseModel):
    preference: str
