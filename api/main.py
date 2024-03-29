import asyncio
from fastapi import FastAPI, HTTPException
import json
import os

from googleApi import GoogleApi
from gptapi import gpt_api
from hotel_scrapper import Hotel_Api
import scrapper
import os
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from models import HotelModel
from models import TravelModel
import uvicorn

import os 
from fastapi.middleware.cors import CORSMiddleware
import random


files = [f for f in os.listdir(".") if os.path.isfile(f)]
json_file = ""
for f in files:
    if f.startswith("gezbot"):
        json_file = f


cred = firebase_admin.credentials.Certificate(json_file)
firebase_admin.initialize_app(cred)
db = firestore.client()
app = FastAPI()
googleApi = GoogleApi()
GPTAPI = gpt_api()
HotelAPI = Hotel_Api()  

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
) 

if __name__ == "__main__":
    uvicorn.run(app, host="10.2.133.35", port=8000)

# uvicorn main:app --reload  --host 10.2.133.35 --port 8000
# https://10.2.133.35:8000

def __select_random_elements(array, num_parts=7):
    # Calculate the length of each part
    part_length = len(array) // num_parts

    # Split the array into parts
    parts = [array[i:i+part_length] for i in range(0, len(array), part_length)]

    # Select random elements from each part
    random_elements = []
    for part in parts:
        random_elements.append(random.choice(part))

    return random_elements


@app.get('/') 
async  def read_root():
    return {"gezBot": "Backend"} 

@app.post("/find_places")
async def find_places(travelModel : TravelModel):
    places = [] 
    TravelData = await travel_details(travelModel.TravelID)
    if TravelData is not None and TravelData != False:
        place = await googleApi.fetch_places_query(TravelData["01_DesiredDestination"])
        place = place[0]["geometry"]["location"]
        coordinates = "{},{}".format(place["lat"], place["lng"])
        TAGS = GPTAPI.Get_google_search_tags(TravelData)
        if TAGS is not None:
            for suggestion in TAGS["suggestions"]:
                query = suggestion["query"]
                types = []
                for type in suggestion["place_types"]:
                    for t in type:
                        types.append(t)

                if types != [] and coordinates != "," and query is not None:
                    try:
                        p, _ = await googleApi.fetch_places_all_methods(
                            query, coordinates, types
                        )
                        for p1 in p: 
                            db.collection("travels").document(travelModel.TravelID).collection('places').document(p1["place_id"]).set(p1) 
                            places.append(p1)
                    except Exception as e:
                        print(e)
      
        selections = __select_random_elements(places)   
        for selection in selections:
            db.collection("travels").document(travelModel.TravelID).collection('selectedPlaces').document(selection["place_id"]).set(selection)           
 
        return True
    return False


@app.post("/query")
async def query(query: str):
    return await googleApi.fetch_places_query(query)
 
@app.get("/travel_details")
async def travel_details(travelID: str):
    try:
        doc = db.collection("travels").document(travelID).get()
        if doc.exists:
            return doc.to_dict()
        else:
            return False
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/travel_exist")
async def travel_exist(travelID: str):
    try:
        doc = db.collection("travels").document(travelID).get()
        if doc.exists:
            return True
        else:
            return False
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# muqlwBIQ0celiszh1d3T
 

# query with from to and departure date and return date
@app.post("/flights")
async def flights(from_: str, to: str, departure_date: str, return_date: str):
    return scrapper._get_flights(from_, to, departure_date, return_date)


@app.post("/find_hotels")
async def find_hotels(hotelProperties : HotelModel ):
    hotels = await HotelAPI.findHotel(
         hotelProperties.place, hotelProperties.checkin, hotelProperties.checkout, 
        hotelProperties.stars, hotelProperties.hotel_types, hotelProperties.hotel_options, hotelProperties.adults,
        hotelProperties.children
    )
    if(await travel_exist(hotelProperties.TravelID) and hotels is not None):
        try:
            cats = ["relevance" , "lowest_price" , "highest_rating" , "most_viewed"]
            for cat in cats: 
                db.collection("travels").document(hotelProperties.TravelID).collection('hotels').document(cat).set({"status": "pending"})  
                for hotel in hotels[cat]: 
                    db.collection("travels").document(hotelProperties.TravelID).collection('hotels').document(cat).collection('hotels').document(hotel).set(hotels[cat][hotel])
    
            try: 
                for cat in cats:
                    selection = __select_random_elements(list(hotels[cat].values()), num_parts=2)
                    for s in selection:
                        db.collection("travels").document(hotelProperties.TravelID).collection('selectedHotels').add(s) 
            except Exception as e:
                print(e) 
        
                 
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        return True
    else:
        return False

'''
{
    place: "istanbul",   
    checkin: "yyyy-mm-dd",
    checkout: "yyyy-mm-dd",
    "HotelStars": [
            3,
            4,
            5
    ],
    "HotelType": [
        "spa",
        "hostel",
        "boutique",
        "bed_and_breakfast",
        "beach",
        "motel",
        "apartment",
        "inn",
        "resort",
        "other"
    ],
    "HotelOptions": [
        "free_wifi",
        "free_breakfast",
        "restaurant",
        "bar",
        "kid_friendly",
        "pet_friendly",
        "free_parking",
        "parking",
        "ev_charger",
        "room_service",
        "fitness_center",
        "spa",
        "pool",
        "indoor_pool",
        "outdoor_pool",
        "air_conditioned",
        "wheelchair_accessible",
        "beach_access",
        "all_inclusive_available"
    ]
}

'''

@app.post("/create_car_route")
async def create_car_route(
    origin_lat: float, origin_lng: float, destination_lat: float, destination_lng: float
):
    origin = {
        "location": {
            "latLng": {
                "latitude": origin_lat,
                "longitude": origin_lng
            }
        }
    }
    destination = {
        "location": {
            "latLng": {
                "latitude": destination_lat,
                "longitude": destination_lng
            }
        }
    }
    return await googleApi.fetch_car_route(query, origin, destination)