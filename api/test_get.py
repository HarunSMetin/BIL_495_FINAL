from fastapi.testclient import TestClient
from main import app  # Adjust this import based on your project structure

client = TestClient(app)
