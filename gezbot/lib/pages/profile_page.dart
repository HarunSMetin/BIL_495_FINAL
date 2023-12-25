import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  Future<Map<String, String>> _getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String userEmail = prefs.getString('userEmail') ?? 'Not available';
    String userName = prefs.getString('userName') ?? 'Not available';
    String userPhotoUrl = prefs.getString('userPhotoUrl') ?? '';
    String userSurname = prefs.getString('userSurname') ?? 'Not available';

    return {
      'email': userEmail,
      'name': userName,
      'photoUrl': userPhotoUrl,
      'surname': userSurname
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
                    radius: 40,
                  ),
                SizedBox(height: 10),
                Text('Name: ${snapshot.data?['name'] ?? 'Not available'}'),
                Text('Email: ${snapshot.data?['email'] ?? 'Not available'}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();

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
