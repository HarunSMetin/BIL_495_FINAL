import requests
import json
import os
class gpt_api:
    def __init__(self, API_KEY=None): 
            exampleInput = {
            "departureDate": "2024-01-03 00:00:00.000",
            "returnDate": "2024-01-04 00:00:00.000",
            "specialComment": "I love eating Pizza. Explore new places and see lots of places",
            "departureLocation": "Ankara",
            "desiredDestination": "Istanbul, Söğütlüçeşme",
            "travelTransportation": "Car",
            "purposeOfVisit": "Cultural experiences and sightseeing",
            "estimatedBudget": 5,
            "accommodationPreferences": "Mid-range",
            "activitiesPreferences": "Relaxation and wellness (e.g., spas, beaches)",
            "dietaryRestrictions": "No restrictions",
            "travelingWithOthers": "Small group (3-5 people)",
            "localRecommendations": "Yes"
            }

            output = {
                "suggestions": [
                    {"place_types": 
                        {"food_and_drink_based": ["pizza_restaurant"],"entertainment_and_recreation_center": ["tourist_attraction"]},"fields": {"atmospheric_data_fields": ["user_ratings_total"]},"query": "Pizza Restaurants in Istanbul, Söğütlüçeşme"},{"place_types": {"culture_based": ["art_gallery", "museum", "performing_arts_theater"],"entertainment_and_recreation_center": ["amusement_center", "historical_landmark", "tourist_attraction"]},"query": "Historical places in Istanbul"},
                    ]
                }

        
            self.PROMPT = "#Description:#You're developing an application to help users plan customized travel itineraries using the Google Maps API. Your task is to process structured JSON input, representing a user's travel details and preferences, and generate a comprehensive list of suggested places to visit and activities to engage in during the specified travel period.#Input:#The input comprises a JSON object with the following fields:- `departureDate`: Date of departure.- `returnDate`: Date of return.- `specialComment`: Additional comments or preferences provided by the user.- Additional fields for specific preferences or constraints.#Example Input:#```json{}```#Process:# Calculate the travel period duration from `departureDate` to `returnDate`. Consider `specialComment` to understand user preferences. Generate suggestions proportional to the travel duration, ensuring 7 suggestions in the list. Select destinations based on predefined tags like parks, restaurants, etc. Customize suggestions with relevant tags and query strings.#Output:# A JSON object with a curated list of suggestions, each containing: Tags categorizing the suggested place/activity. Query strings for Google Maps API.#Example Output:# {} #Constraints:# Ensure diverse suggestions catering to various interests. Output adheres to specified structure with relevant tags and queries. Provide 7 suggestion in the list. Output must contain 7 SUGGESTION ELEMENTS . Here is the Travel data for you make Suggestions YOU MUST PROVIDE FULL STRUCTURE AS JSON: ".format(exampleInput, output) 


            self.endpoint = "https://api.openai.com/v1/chat/completions"
            self.api_key = ""

            self.current_file_path = os.path.abspath(__file__) 
            self.directory_path = os.path.dirname(self.current_file_path) 

            with open(os.path.join(self.directory_path, "config.json") , 'r') as f:
                 self.api_key = json.load(f)['gpt_api_key']
    


    def __call_gpt_api(self,prompt):  # Replace this with your OpenAI API key

        headers = {"Content-Type": "application/json", "Authorization": f"Bearer {self.api_key}"}

        data = {
            "model": "gpt-3.5-turbo",  # Adjust the model name as per your preference
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.3,  # Adjust the temperature as per your preference
        }

        response = requests.post(self.endpoint, headers=headers, json=data)
        if response.status_code == 200:
            print(response.json()["usage"])
            return response.json()["choices"][0]["message"]["content"]
        else:
            print(f"Failed with status code {response.status_code}")
            return ""

    def Get_google_search_tags(self,TravelData,PersonalPref = None, save=False):  

        self.PROMPT = self.PROMPT + json.dumps(TravelData, indent=4, sort_keys=True, default=str)
        if PersonalPref != None:
            self.PROMPT = self.PROMPT + json.dumps(PersonalPref,  indent=4, sort_keys=True, default=str)
        generated_text = self.__call_gpt_api(self.PROMPT) 
        jsonData={}
        try:
            jsonData = json.loads(generated_text)
        except json.decoder.JSONDecodeError as e:
            print(f"Error decoding JSON: {e}") 

        if save:
            try:
                generated_text_file_path = os.path.join(self.directory_path, "generated_text.json") 
                with open(generated_text_file_path, "w") as file:
                    file.write(json.dumps(jsonData)) 
                print(len(jsonData["suggestions"])) 
            except json.decoder.JSONDecodeError as e:
                print(f"Error decoding JSON: {e}") 
        print(jsonData)
        return jsonData
    