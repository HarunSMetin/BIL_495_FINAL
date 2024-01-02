import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfilePage extends StatelessWidget {
  Future<Map<String, String>> _getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String userEmail = prefs.getString('userEmail') ?? 'Not available';
    String userName = prefs.getString('userName') ?? 'Not available';
    String userPhotoUrl = prefs.getString('photoUrl') ?? '';
    String userBirthDate = prefs.getString('birthDate') ?? 'Not available';
    String userGender = prefs.getString('gender') ?? 'Not available';

    return {
      'email': userEmail,
      'name': userName,
      'photoUrl': userPhotoUrl,
      'birthDate': userBirthDate,
      'gender': userGender,
    };
  }

  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _getUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Profile Tab', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                if (snapshot.data?['photoUrl'] != '')
                  CircleAvatar(
                    backgroundImage: NetworkImage(snapshot.data!['photoUrl']!),
                    radius: MediaQuery.of(context).size.width / 5,
                    
                  ),
                SizedBox(height: 10),
                Text('Username: ${snapshot.data?['name'] ?? 'Not available'}'),
                Text('Email: ${snapshot.data?['email'] ?? 'Not available'}'),
                Text('Birth Date: ${snapshot.data?['birthDate'] ?? 'Not available'}'),
                Text('Gender: ${snapshot.data?['gender'] ?? 'Not available'}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    final GoogleSignIn _googleSignIn = GoogleSignIn(clientId: "1027985224810-jeioofe75dtanigd4r1vtgv4v4glemis.apps.googleusercontent.com");

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    await _googleSignIn.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
