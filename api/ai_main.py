from fastapi import FastAPI, HTTPException
from firebase_admin import credentials, firestore, auth
import firebase_config
from models import UserCreate

app = FastAPI()
db = firestore.client()
from fastapi import FastAPI, HTTPException
from firebase_admin import firestore, auth
import firebase_config  # This will initialize Firebase
from models import UserCreate, UserLogin

app = FastAPI()
db = firestore.client()


@app.get("/")
def read_root():
    return {"gezBot": "AI"}
