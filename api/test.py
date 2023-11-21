from fastapi.testclient import TestClient
from main import app  # Adjust this import based on your project structure

client = TestClient(app)

# Replace these with valid IDs for real tests
TEST_USER_ID = "test_user_id"
TEST_TRAVEL_ID = "test_travel_id"
TEST_CREATOR_ID = "test_creator_id"

def test_get_user():
    response = client.get(f"/users/{TEST_USER_ID}")
    assert response.status_code in [200, 404]

def test_get_travels_by_creator():
    response = client.get("/travels", params={"creator_id": TEST_CREATOR_ID})
    assert response.status_code == 200

def test_get_chat_messages():
    response = client.get(f"/chats/{TEST_TRAVEL_ID}/messages")
    assert response.status_code == 200

def test_get_user_options():
    response = client.get(f"/userOptions/{TEST_TRAVEL_ID}", params={"user_id": TEST_USER_ID})
    assert response.status_code == 200

# Additional tests for other endpoints can be added here