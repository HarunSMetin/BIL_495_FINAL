from pydantic import BaseModel


class ReviewRequest(BaseModel):
    review: str


class RestaurantResponse(BaseModel):
    name: str
    similarity_score: float
