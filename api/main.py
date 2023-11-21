from fastapi import FastAPI, HTTPException
from firebase_admin import credentials,firestore,auth
import firebase_config 
from models import UserCreate

app = FastAPI()
db = firestore.client()  
from fastapi import FastAPI, HTTPException
from firebase_admin import firestore, auth
import firebase_config  # This will initialize Firebase
from models import UserCreate

app = FastAPI()
db = firestore.client()

# Function to add a new user
def add_new_user(user_id, email, name, profile_pic):
    user_data = {
        'email': email,
        'name': name,
        'profilePic': profile_pic,
        'createdAt': firestore.SERVER_TIMESTAMP
    }
    db.collection('users').document(user_id).set(user_data)

# Function to send a friend request
def send_friend_request(sender_id, receiver_id):
    friend_request_data = {
        'senderId': sender_id,
        'receiverId': receiver_id,
        'sentAt': firestore.SERVER_TIMESTAMP,
        'status': 'pending'
    }
    request_id = f'{sender_id}_{receiver_id}'
    db.collection('friendRequests').document(request_id).set(friend_request_data)

# Function to accept a friend request
def accept_friend_request(request_id, sender_id, receiver_id):
    with db.transaction() as transaction:
        friend_request_ref = db.collection('friendRequests').document(request_id)
        transaction.update(friend_request_ref, {'status': 'accepted'})

        transaction.set(db.collection('users').document(sender_id).collection('friends').document(receiver_id), {'friendId': receiver_id, 'friendSince': firestore.SERVER_TIMESTAMP})
        transaction.set(db.collection('users').document(receiver_id).collection('friends').document(sender_id), {'friendId': sender_id, 'friendSince': firestore.SERVER_TIMESTAMP})

# FastAPI Endpoints
@app.post("/register")
async def create_user(user: UserCreate):
    try:
        user_record = auth.create_user(
            email=user.email,
            password=user.password
        )
        add_new_user(user_record.uid, user.email, user.name, "default_profile_pic_url")
        return {"uid": user_record.uid}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/send_friend_request/{sender_id}/{receiver_id}")
async def send_request(sender_id: str, receiver_id: str):
    try:
        send_friend_request(sender_id, receiver_id)
        return {"detail": "Friend request sent."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/accept_friend_request/{request_id}/{sender_id}/{receiver_id}")
async def accept_request(request_id: str, sender_id: str, receiver_id: str):
    try:
        accept_friend_request(request_id, sender_id, receiver_id)
        return {"detail": "Friend request accepted."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/travels")
async def create_travel(title: str, description: str, creator_id: str, travel_details: dict, visibility: str, visible_to: list = None):
    travel_data = {
        'title': title,
        'description': description,
        'creatorId': creator_id,
        'createdAt': firestore.SERVER_TIMESTAMP,
        'travelDetails': travel_details,
        'visibility': visibility,  # 'friends' or 'everyone'
        'visibleTo': visible_to if visibility == 'friends' else None
    }
    travel_ref = db.collection('travels').add(travel_data)
    return {"travelId": travel_ref[1].id}

@app.post("/chats/{travel_id}/message")
async def add_message_to_chat(travel_id: str, user_id: str, message: str):
    message_data = {
        'userId': user_id,
        'message': message,
        'sentAt': firestore.SERVER_TIMESTAMP
    }
    db.collection('chats').document(travel_id).collection('messages').add(message_data)
    return {"detail": "Message added to chat."}

@app.post("/userOptions/{user_id}/{travel_id}")
async def add_user_options(user_id: str, travel_id: str, selected_options: dict, additional_comments: str = None):
    options_data = {
        'userId': user_id,
        'travelId': travel_id,
        'selectedOptions': selected_options,
        'additionalComments': additional_comments
    }
    db.collection('userOptions').document(f"{user_id}_{travel_id}").set(options_data)
    return {"detail": "User options added."}



@app.get("/users/{user_id}")
async def get_user(user_id: str):
    user_ref = db.collection('users').document(user_id)
    user_doc = user_ref.get()
    if user_doc.exists:
        return user_doc.to_dict()
    else:
        raise HTTPException(status_code=404, detail="User not found")
    
@app.get("/travels")
async def get_travels_by_creator(creator_id: str = None):
    travels_ref = db.collection('travels')
    if creator_id:
        travels_ref = travels_ref.where('creatorId', '==', creator_id)
    travels = travels_ref.stream()
    return [travel.to_dict() for travel in travels]

@app.get("/chats/{travel_id}/messages")
async def get_chat_messages(travel_id: str):
    messages_ref = db.collection('chats').document(travel_id).collection('messages').order_by('sentAt')
    messages = messages_ref.stream()
    return [message.to_dict() for message in messages]

@app.get("/userOptions/{travel_id}")
async def get_user_options(travel_id: str, user_id: str = None):
    options_ref = db.collection('userOptions')
    if user_id:
        options_ref = options_ref.where('userId', '==', user_id).where('travelId', '==', travel_id)
    else:
        options_ref = options_ref.where('travelId', '==', travel_id)
    options = options_ref.stream()
    return [option.to_dict() for option in options]