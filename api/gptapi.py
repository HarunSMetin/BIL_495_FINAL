import requests
import json

traveldata = {
    "id": "PsSAcQDOSL4g5b6q7O7FN",
    "name": "Ankara - Izmir Travel",
    "description": "Travel",
    "creatorId": "TDPuYUpUqvhzzVTAZoRnpw68Ym73",
    "isPublic": True,
    "isCompleted": True,
    "lastUpdate": "2024-02-08 00:00:00.000",
    "members": ["TDPuYUpUqvhzzVTAZoRnpw68Ym73"],
    "departureDate": "2024-02-08 00:00:00.000",
    "returnDate": "2024-02-10 00:00:00.000",
    "departureLocation": "Ankara",
    "desiredDestination": "Izmir",
    "travelTransportation": "Bus",
    "purposeOfVisit": "Cultural experiences and sightseeing",
    "estimatedBudget": 5000,
    "accommodationPreferences": "Mid-range",
    "activitiesPreferences": "Relaxation and wellness (e.g., spas, beaches)",
    "dietaryRestrictions": "No restrictions",
    "travelingWithOthers": "Just Me",
    "specialComment": "I love eating  local food and I am a big fan of Turkish cuisine. I would like to try local restaurants and street food. I am also interested in local recommendations for sightseeing and cultural experiences.",
    "localRecommendations": "Yes",
    "lastUpdatedQuestionId": "12_LocalRecommendations",
}


def call_gpt_api(prompt):
    endpoint = "https://api.openai.com/v1/chat/completions"
    api_key = "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"  # Replace this with your OpenAI API key

    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {api_key}"}

    data = {
        "model": "gpt-3.5-turbo",  # Adjust the model name as per your preference
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.7,  # Adjust the temperature as per your preference
    }

    response = requests.post(endpoint, headers=headers, json=data)

    if response.status_code == 200:
        return response.json()["choices"][0]["message"]["content"]
    else:
        print(f"Failed with status code {response.status_code}")
        return None


# Example usage
with open("prompt.txt", "r") as file:
    prompt = file.read()
prompt = prompt + json.dumps(traveldata)
generated_text = call_gpt_api(prompt)
print("Generated Text:", generated_text)
