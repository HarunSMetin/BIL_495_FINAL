from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    name: str
    profilePic: str  # URL to the user's profile picture
    
class UserLogin(BaseModel):
    email: str
    password: str