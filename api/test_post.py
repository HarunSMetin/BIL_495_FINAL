from fastapi.testclient import TestClient
from main import app  # Adjust this import based on your project structure

client = TestClient(app)

# Test data - replace with valid test data
TEST_USER_ID = "test_user_id"
TEST_TRAVEL_ID = "test_travel_id"
TEST_CREATOR_ID = "test_creator_id"


# POST Endpoint Tests
def test_create_user():
    user_data = {
        "email": "testuser3ssss@example.com",
        "password": "testpassword",
        "name": "Test User",
        "profilePic": "http://example.com/profile.jpg"
    }
    response = client.post("/register", json=user_data)
    assert response.status_code == 200
    assert "uid" in response.json()

def test_send_friend_request():
    sender_id = "test_sender_id"
    receiver_id = "test_receiver_id"
    response = client.post(f"/send_friend_request/{sender_id}/{receiver_id}")
    assert response.status_code == 200

def test_create_travel():
    travel_data = {
        "title": "Test Travelss",
        "description": "A test travels",
        "creator_id": "test_creator_id1",
        "travel_details": {"destination": "Testville"},
        "visibility": "everyone"
    }
    response = client.post("/travels", json=travel_data)
    assert response.status_code == 200
    assert "travelId" in response.json()

def test_add_user_options():
    options_data = {
        "user_id": "test_user_id",
        "travel_id": "test_travel_id",
        "selected_options": {"option1": "value1"},
        "additional_comments": "Test comment"
    }
    response = client.post(f"/userOptions/{options_data['user_id']}/{options_data['travel_id']}", json=options_data)
    assert response.status_code == 200
    
    