import asyncio
from fastapi import FastAPI
from firebase_admin import firestore

from googleApi import GoogleApi 


app = FastAPI()  
googleApi = GoogleApi()   

@app.get("/")
def read_root():
    return {"gezBot": "Backend"}


@app.post("/create_hotel_suggestions")
async def create_hotel_suggestions(travelID : str ,city: str, checkin: str, checkout: str, adults: int, additionals: dict):
    
    hotels = asyncio.get_event_loop().run_until_complete(googleApi.fetch_places_nearby("41.035625,28.9765617", ["hotel"]))
    return {"city": city, "checkin": checkin, "checkout": checkout, "adults": adults} # TODO: Implement

 