import requests
import json
import os

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
    "travelingWithOthers": "Small group (3-5 people)","localRecommendations": "Yes"
    }

output = {
    "suggestions": [
        {"place_types": 
            {"food_and_drink_based": ["pizza_restaurant"],"entertainment_and_recreation_center": ["tourist_attraction"]},"fields": {"atmospheric_data_fields": ["user_ratings_total"]},"query": "Pizza Restaurants in Istanbul, Söğütlüçeşme"},{"place_types": {"culture_based": ["art_gallery", "museum", "performing_arts_theater"],"entertainment_and_recreation_center": ["amusement_center", "historical_landmark", "tourist_attraction"]},"query": "Historical places in Istanbul"},
        ]
    }

traveldata = {
    "id": "PsSAcQDOSL4g5b6q7O7FN",
    "name": "Ankara - Çanakkale Travel",
    "description": "Travel",
    "creatorId": "TDPuYUpUqvhzzVTAZoRnpw68Ym73",
    "isPublic": True,
    "isCompleted": True,
    "lastUpdate": "2024-02-08 00:00:00.000",
    "members": ["TDPuYUpUqvhzzVTAZoRnpw68Ym73"],
    "departureDate": "2024-02-08 00:00:00.000",
    "returnDate": "2024-02-15 00:00:00.000",
    "departureLocation": "Ankara",
    "desiredDestination": "Çanakkale",
    "travelTransportation": "Bus",
    "purposeOfVisit": "Cultural experiences and sightseeing",
    "estimatedBudget": 5000,
    "accommodationPreferences": "Mid-range",
    "activitiesPreferences": "Relaxation and wellness (e.g., spas, beaches)",
    "dietaryRestrictions": "No restrictions",
    "travelingWithOthers": "Just Me",
    "specialComment": "I am a student and I want to visit the historical places in Çanakkale. I want to stay in a hotel with a sea view. I want to visit the beaches and the historical places in Çanakkale. I want to eat local food and I want to try the local desserts. I want to visit the historical places in Çanakkale. I want to stay in a hotel with a sea view. I want to visit the beaches and the historical places in Çanakkale. I want to eat local food and I want to try the local desserts. I want to visit the historical places in Çanakkale. I want to stay in a hotel with a sea view. I want to visit the beaches and the historical places in Çanakkale. I want to eat local food and I want to try the local desserts. I want to visit the historical places in Çanakkale. I want to stay in a hotel with a sea view. I want to visit the beaches and the historical places in Çanakkale. I want to eat local food and I want to try the local desserts. I want to visit the historical places in Çanakkale. I want to stay in a hotel with a sea view. I want to visit the beaches and the historical places in Çanakkale. I want to eat local food and I want to try the local desserts. I want to visit the historical places in Çanakkale. I want to stay in a hotel with a sea view. I want to visit the beaches and the historical places in Çanakkale. I want to eat local food and I want to try the local desserts. I want to visit the historical places in Çanakkale. I want to stay in a hotel with a sea view. I want to visit the beaches and the historical places in Çanakkale. I want to eat local food and I want to try the local desserts. I want to visit the historical places in Çanakkale. I want to stay in a hotel with a sea view. I want to visit the beaches and the historical places in Çanakkale. I want to eat local food and I want to try the local desserts. I want to visit the historical places in Çanakkale. I want to stay in a hotel with a sea view. I want to visit the beaches and the historical places in Çanakkale. I want to eat local",
    "localRecommendations": "Yes",
    "lastUpdatedQuestionId": "12_LocalRecommendations",
}

PROMPT = "#Description:#You're developing an application to help users plan customized travel itineraries using the Google Maps API. Your task is to process structured JSON input, representing a user's travel details and preferences, and generate a comprehensive list of suggested places to visit and activities to engage in during the specified travel period.#Input:#The input comprises a JSON object with the following fields:- `departureDate`: Date of departure.- `returnDate`: Date of return.- `specialComment`: Additional comments or preferences provided by the user.- Additional fields for specific preferences or constraints.#Example Input:#```json{}```#Process:#1. Calculate the travel period duration from `departureDate` to `returnDate`.2. Consider `specialComment` to understand user preferences.3. Generate suggestions proportional to the travel duration, ensuring 10 suggestions in the list.4. Select destinations based on predefined tags like parks, restaurants, etc.5. Customize suggestions with relevant tags and query strings.#Output:#A JSON object with a curated list of suggestions, each containing:- Tags categorizing the suggested place/activity.- Query strings for Google Maps API.#Example Output:#{}#Constraints:#- Ensure diverse suggestions catering to various interests.- Output adheres to specified structure with relevant tags and queries.- Provide 10 suggestion in the list. Output must contain 10 SUGGESTION ELEMENTS . Here is the Travel data for you make Suggestions YOU MUST PROVIDE FULL STRUCTURE AS JSON: ".format(exampleInput, output) 


endpoint = "https://api.openai.com/v1/chat/completions"
api_key = ""

current_file_path = os.path.abspath(__file__) 
directory_path = os.path.dirname(current_file_path) 

with open(os.path.join(directory_path, "config.json") , 'r') as f:
    api_key = json.load(f)['gpt_api_key']

def __call_gpt_api(prompt):  # Replace this with your OpenAI API key

    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {api_key}"}

    data = {
        "model": "gpt-3.5-turbo",  # Adjust the model name as per your preference
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.3,  # Adjust the temperature as per your preference
    }

    response = requests.post(endpoint, headers=headers, json=data)
    if response.status_code == 200:
        print(response.json()["usage"])
        return response.json()["choices"][0]["message"]["content"]
    else:
        print(f"Failed with status code {response.status_code}")
        return ""

def Get_google_search_tags(TravelData,PersonalPref = None, save=False):  

    PROMPT = PROMPT + json.dumps(TravelData) 
    if PersonalPref != None:
        PROMPT = PROMPT + json.dumps(PersonalPref) 
    generated_text = __call_gpt_api(PROMPT) 
    jsonData={}
    try:
        jsonData = json.loads(generated_text)
    except json.decoder.JSONDecodeError as e:
        print(f"Error decoding JSON: {e}") 

    if save:
        try:
            generated_text_file_path = os.path.join(directory_path, "generated_text.json") 
            with open(generated_text_file_path, "w") as file:
                file.write(json.dumps(jsonData)) 
            print(len(jsonData["suggestions"])) 
        except json.decoder.JSONDecodeError as e:
            print(f"Error decoding JSON: {e}") 
    print(jsonData)
    return jsonData
 