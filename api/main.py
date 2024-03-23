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

import os

import scrape


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


@app.get("/")
def read_root():
    return {"gezBot": "Backend"}


@app.post("/create_hotel_suggestions")
async def create_hotel_suggestions(
    travelID: str, coordinates: str, checkin: str, checkout: str, adults: int
):
    hotels = []
    if coordinates != "":
        try:
            hotels = await googleApi.__fetch_places_nearby(coordinates, ["hotel"])
        except:
            hotels = []

    return hotels


@app.post("/create_place_suggestions")
async def create_place_suggestions(travel_id: str):
    places = []
    counts = [0, 0]
    TravelData = await travel_details(travel_id)
    if TravelData is not None:
        place = await googleApi.fetch_places_query(TravelData["03_DesiredDestination"])
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
                        p, counts = await googleApi.fetch_places_all_methods(
                            query, coordinates, types
                        )
                        for p1 in p:
                            places.append(p1)
                    except Exception as e:
                        print(e)

            print(len(places))
            print("query_places : ", counts[0])
            print("nearby_places : ", counts[1])

        return places
    return "null"


@app.post("/query")
async def query(query: str):
    return await googleApi.fetch_places_query(query)


@app.get("/travel_details/{travelID}")
async def travel_details(travelID: str):
    try:
        doc = db.collection("travels").document(travelID).get()
        if doc.exists:
            return doc.to_dict()
        else:
            raise HTTPException(status_code=404, detail="Travel not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# muqlwBIQ0celiszh1d3T


# query with from to and departure date and return date
@app.post("/flights")
async def flights(from_: str, to: str, departure_date: str, return_date: str):
    return scrapper._get_flights(from_, to, departure_date, return_date)


@app.post("/get_hotels")
async def get_hotels(
    place: str,
    checkin: str,
    checkout: str,
    stars=[3, 4, 5],
    hotel_types=["hostel", "boutique", "motel", "inn", "resort", "other"],
    hotel_options=["free_wifi", "free_breakfast", "air_conditioned"],
    adults=1,
    children=0,
):
    return await HotelAPI.findHotel(
        place, checkin, checkout, stars, hotel_types, hotel_options, adults, children
    )
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