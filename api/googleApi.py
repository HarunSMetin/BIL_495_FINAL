import requests
import time
import json
 

class GoogleApi: 
    def __init__(self, API_KEY=None): 
        apikey = ""
        with open('config.json', 'r') as f:
            apikey = json.load(f)['google_api_key']
        self.API_KEY = API_KEY or apikey
    
    async def get_function(self,url,params,limit=False):
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
            if limit or not next_page_token :
                break 
            time.sleep(2) 
            params["pagetoken"] = next_page_token

        return places

    async def post_function(self,url, json:dict):
        response = requests.post(url, json=json) 
        if response.status_code != 200 :
            return f"Error making API request! Response Code : {response.status_code }"
        elif response.json().get("status")  != "OK":
            return f"Error making API request! Status : {response.json().get('status') }"
        return response.json()
    


    async def __fetch_places_nearby(self, location, types , radius=50000, language="tr" ): 
        url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json" 
        params = { 
            "location": location,
            "radius": radius,
            "key": self.API_KEY,
            "language": language, 
            "type": "|".join(types),
            "businessStatus" : "OPERATIONAL",

        } 
        return await self.get_function(url,params) 

    async def fetch_places_query(self, queryString : str, types=[], limit = False):
        places = []
        url = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        params = {  
            "query": queryString, 
            "key": self.API_KEY, 
        }
        if types != []:
            params["type"] = "|".join(types)
        return await self.get_function(url,params,limit=limit)  

    async def fetch_places_all_methods(self, queryString="", location="", types=[], radius=15000, language="tr"):
        places = []
        counts = [0,0]
        flag = False
        if queryString !="" : 
            query_places = await self.fetch_places_query(queryString,types)
            for place in query_places:
                flag = False
                for p in places:
                    if p["place_id"] == place["place_id"]:
                        flag = True
                        break 
                if not flag:
                    places.append(place)
                    counts[0]+=1  

        if location!="" and types!=[]:
            nearby_places = await self.__fetch_places_nearby(location, types, radius, language)

            for place in nearby_places:
                flag = False
                for p in places:
                    if p["place_id"] == place["place_id"]:
                        flag = True
                        break 
                if not flag:
                    places.append(place)
                    counts[1]+=1   
        return places,counts   

    async def fetch_place_details(self ,place_id):
        url = "https://maps.googleapis.com/maps/api/place/details/json"
        params = {
            "place_id": place_id,
            "key": self.API_KEY,
            "region": "TR"
        } 
        return await self.get_function(url,params) 
    
    async def fetch_car_route(self, origin, destination, intermediates=None, travel_mode="DRIVE", routing_preference=None, polyline_quality=None, polyline_encoding=None, departure_time=None, arrival_time=None, alternative_routes=True, route_modifiers=None, language="tr", region="TR", units="metric", optimize_waypoint_order=True, requested_reference_routes=None, extra_computations=None, traffic_model=None, transit_preferences=None):
        url = "https://routes.googleapis.com/directions/v2:computeRoutes"
        params = {
            "origin": origin,
            "destination": destination,
            "intermediates": intermediates,
            "key": self.API_KEY,
            "travelMode": travel_mode,
            "routingPreference": routing_preference,
            "polylineQuality": polyline_quality,
            "polylineEncoding": polyline_encoding,
            "departureTime": departure_time,
            "arrivalTime": arrival_time,
            "computeAlternativeRoutes": alternative_routes,
            "routeModifiers": route_modifiers,
            "languageCode": language,
            "regionCode": region,
            "units": units,
            "optimizeWaypointOrder": optimize_waypoint_order,
            "requestedReferenceRoutes": requested_reference_routes,
            "extraComputations": extra_computations,
            "trafficModel": traffic_model,
            "transitPreferences": transit_preferences
        }
        return await self.get_function(url,params)