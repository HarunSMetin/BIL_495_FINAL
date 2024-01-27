from fastapi import FastAPI
from firebase_admin import firestore

app = FastAPI()
db = firestore.client()


@app.get("/")
def read_root():
    return {"gezBot": "AI"}
