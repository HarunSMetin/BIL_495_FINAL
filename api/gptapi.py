import requests
import json

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


def call_gpt_api(prompt):
    endpoint = "https://api.openai.com/v1/chat/completions"
    api_key = "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"  # Replace this with your OpenAI API key

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


import os

# Get the absolute path of the current file
current_file_path = os.path.abspath(__file__)

# Get the directory path of the current file
directory_path = os.path.dirname(current_file_path)

# Construct the absolute path of the prompt file
prompt_file_path = os.path.join(directory_path, "pr.txt")

# Read the prompt from the file
with open(prompt_file_path, "r") as file:
    prompt = file.read()

# Append the traveldata to the prompt
prompt = prompt + json.dumps(traveldata)

# Call the GPT API
generated_text = call_gpt_api(prompt)

# Construct the absolute path of the generated text file
generated_text_file_path = os.path.join(directory_path, "generated_text.json")

try:
    jsonData = json.loads(generated_text)
    # Continue with the rest of your code that uses jsonData
except json.decoder.JSONDecodeError as e:
    print(f"Error decoding JSON: {e}")

    # Handle the error appropriately

# Save the generated text to a file as JSON
with open(generated_text_file_path, "w") as file:
    file.write(json.dumps(jsonData))

print(len(jsonData["suggestions"]))
