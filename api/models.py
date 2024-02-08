from typing import List
from pydantic import BaseModel, EmailStr


class PlaceCoordinates(BaseModel):
    lat: float
    lng: float


class RecommendedPlacesResponse(BaseModel):
    initialPosition: PlaceCoordinates
    pointsToMark: List[PlaceCoordinates]
