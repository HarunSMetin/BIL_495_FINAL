import asyncio
from fastapi import FastAPI, HTTPException
from firebase_admin import firestore
from api.models import PlaceCoordinates, RecommendedPlacesResponse

from googleApi import GoogleApi


app = FastAPI()
googleApi = GoogleApi()
db = firestore.client()


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
async def create_place_suggestions(travelID: str, coordinates: str, additionals: dict):
    places = []
    counts = [0, 0]
    if (
        additionals is not None
        and additionals["placeType"] is not None
        and coordinates != ""
        and additionals["query"] is not None
    ):
        try:
            places, counts = await googleApi.fetch_places_all_methods(
                additionals["query"], coordinates, additionals["placeType"]
            )
        except Exception as e:
            print(e)
    print(len(places))
    print("query_places : ", counts[0])
    print("nearby_places : ", counts[1])
    return places


@app.post("/query")
async def query(query: str):
    return await googleApi.fetch_places_query(query)


"""
@app.post("/recommended_places_coordinates/{travelID}")
async def recommended_places_coordinates(travelID: str):
    try:
        # Fetch travel details from Firestore
        doc_ref = db.collection("travels").document(travelID)
        doc = await doc_ref.get()
        if doc.exists:
            travel_data = doc.to_dict()

            # Assuming initialPosition is a string "lat,lng"
            initial_position_str = travel_data.get("initialPosition", "0,0")
            initial_lat, initial_lng = map(float, initial_position_str.split(","))
            initial_position = {"lat": initial_lat, "lng": initial_lng}

            # Assuming pointsToMark is a list of strings ["lat,lng", "lat,lng", ...]
            points_to_mark_str = travel_data.get("pointsToMark", [])
            points_to_mark = [
                {
                    "lat": float(lat_lng.split(",")[0]),
                    "lng": float(lat_lng.split(",")[1]),
                }
                for lat_lng in points_to_mark_str
            ]
            response = RecommendedPlacesResponse(
                initialPosition=PlaceCoordinates(**initial_position),
                pointsToMark=[PlaceCoordinates(**point) for point in points_to_mark],
            )
            return response
        else:
            raise HTTPException(status_code=404, detail="Travel not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
"""
