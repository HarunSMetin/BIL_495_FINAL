import requests
import time

class GoogleApi: 
    def __init__(self, API_KEY=None):
        self.API_KEY = API_KEY or "YOUR_API_KEY"
    
    async def get_function(self,url,params):
        places = []
        while True:
            response = requests.get(url, params=params) 
            if response.status_code != 200 :
                return f"Error making API request! Response Code : {response.status_code }"
            elif response.json().get("status")  != "OK":
                return f"Error making API request! Status : {response.json().get('status') }"

            data = response.json() 
            results = data.get("results", [])
            for result in results:
                places.append(result)
                 
            next_page_token = data.get("next_page_token")
            if not next_page_token :
                break 
            time.sleep(2) 
            params["pagetoken"] = next_page_token

        return places

    async def fetch_places_nearby(self, location, types , radius=50000, language="tr" ): 
        url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json" 
        params = {
            "location": location,
            "radius": radius,
            "key": self.API_KEY,
            "language": language, 
            "type": "|".join(types) 
        } 
        return await self.get_function(url,params) 

    async def fetch_places_text(self,input : str):
        places = []
        url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
        params = {
            "input": input,
            "inputtype": "textquery",
            "key": self.API_KEY, 
        }
        return await self.get_function(url,params) 
     
    async def fetch_places_query(self, input : str):
        places = []
        url = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        params = {
            "query": input,
            "key": self.API_KEY,
        }
        return await self.get_function(url,params)  

    async def fetch_place_details(self ,place_id):
        url = "https://maps.googleapis.com/maps/api/place/details/json"
        params = {
            "place_id": place_id,
            "key": self.API_KEY,
            "region": "TR"
        } 
        return await self.get_function(url,params) 
    
    async def fetch_car_route(self ,origin, destination, mode="driving", alternatives=True, avoid=None, language="tr", units="metric", departure_time=None, arrival_time=None, transit_mode=None, transit_routing_preference=None, traffic_model=None):
        url = "https://maps.googleapis.com/maps/api/directions/json"
        params = {
            "origin": origin,
            "destination": destination,
            "key": self.API_KEY,
            "mode": mode,
            "alternatives": alternatives,
            "avoid": avoid,
            "language": language,
            "units": units,
            "departure_time": departure_time,
            "arrival_time": arrival_time,
            "transit_mode": transit_mode,
            "transit_routing_preference": transit_routing_preference,
            "traffic_model": traffic_model
        }
        return await self.get_function(url,params) 
 
