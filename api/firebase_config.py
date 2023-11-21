import firebase_admin

cred = firebase_admin.credentials.Certificate('./gezbot-112ee-firebase-adminsdk-2ul3v-5240d2f6ae.json')
firebase_admin.initialize_app(cred)