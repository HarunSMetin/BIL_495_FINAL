from fastapi import FastAPI, HTTPException
from firebase_admin import credentials,firestore,auth
import firebase_config 
from models import UserCreate

app = FastAPI()
db = firestore.client()  

#home
@app.get("/")
async def root():
    return {"message": "gezBot API"}


@app.post("/register")
async def create_user(user: UserCreate):
    try:
        user_record = auth.create_user(
            email=user.email,
            password=user.password
        )
        print('Sucessfully created new user: {0}'.format(user_record.uid))
        return {"uid": user_record.uid}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))