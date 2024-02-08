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
async def create_hotel_suggestions(travelID : str , coordinates: str, checkin: str, checkout: str, adults: int):
    hotels= []
    if coordinates != "":
        try:
            hotels =await googleApi.__fetch_places_nearby(coordinates, ["hotel"])
        except:
            hotels = []

    return hotels

@app.post("/create_place_suggestions")
async def create_place_suggestions(travelID: str, coordinates: str, additionals: dict ):
    places = []
    counts = [0,0]
    if additionals is not None and additionals["placeType"] is not None and coordinates != "" and additionals["query"] is not None:
        try:
            places,counts = await googleApi.fetch_places_all_methods(additionals["query"],coordinates, additionals["placeType"])
        except Exception as e:
            print(e)
    print(len(places) )
    print("query_places : ",counts[0])
    print("nearby_places : ",counts[1]) 
    return places


@app.post("/query")
async def query(query:str):
    return await googleApi.fetch_places_query(query)