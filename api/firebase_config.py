import firebase_admin
from firebase_admin import credentials
import firebase_admin

cred = credentials.Certificate('./gezbot-112ee-firebase-adminsdk-2ul3v-1fcd537c05.json')
firebase_admin.initialize_app(cred)