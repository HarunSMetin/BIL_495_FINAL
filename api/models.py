from typing import List
from pydantic import BaseModel, EmailStr


class PlaceCoordinates(BaseModel):
    lat: float
    lng: float


class RecommendedPlacesResponse(BaseModel):
    initialPosition: PlaceCoordinates
    pointsToMark: List[PlaceCoordinates]

class HotelModel(BaseModel):
    TravelID : str
    place  : str
    checkin : str #"2024-12-31"
    checkout : str #"2024-12-31"
    stars :list[int] #[1,2,3,4,5]
    hotel_types : list[str] #["hostel", "boutique", "inn", "resort", "other"]
    hotel_options: list[str] #["free_wifi", "free_breakfast", "air_conditioned"]
    adults : int 
    children: int 

class TravelModel(BaseModel):
    TravelID: str 