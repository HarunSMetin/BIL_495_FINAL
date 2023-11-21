import firebase_admin
import os
files = [f for f in os.listdir('.') if os.path.isfile(f)]
json_file = ""
for f in files:
    if f.startswith("gezbot"):
        json_file = f


cred = firebase_admin.credentials.Certificate(json_file)
firebase_admin.initialize_app(cred)