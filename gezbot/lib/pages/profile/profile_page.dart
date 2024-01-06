import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gezbot/services/user_service.dart'; // Import UserService

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService(); // Instance of UserService
  late Future<Map<String, String>> userDetailsFuture;

  @override
  void initState() {
    super.initState();
    userDetailsFuture = _getUserDetails();
  }

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

  Future<void> _refreshUserDetails() async {
    setState(() {
      _getUserDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    void _showErrorDialog(String? message) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('An error occurred'),
          content: Text(message ?? 'Unknown error'),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }

    void _updateProfile(
        BuildContext context, String field, String userId) async {
      TextEditingController _controller = TextEditingController();
      late Future<void> Function() updateFunction;

      // Define the update function based on the field
      switch (field) {
        case 'username':
          updateFunction = () async {
            await _userService.updateUsername(
                userId: userId, username: _controller.text);
            await _refreshUserDetails();
          };
          break;
        case 'birth date':
          updateFunction = () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (selectedDate != null) {
              await _userService.updateUserBirthDate(
                  userId: userId, birthDate: selectedDate);
              await _refreshUserDetails();
            }
          };
          break;
        case 'gender':
          updateFunction = () async {
            String? selectedGender = await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                  title: const Text('Select Gender'),
                  children: <Widget>[
                    SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, 'Male');
                      },
                      child: const Text('Male'),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, 'Female');
                      },
                      child: const Text('Female'),
                    ),
                    // Add more options here if needed
                  ],
                );
              },
            );
            if (selectedGender != null) {
              await _userService.updateGender(
                  userId: userId, gender: selectedGender);
              await _refreshUserDetails();
            }
          };
          break;
        // ... other cases
      }

      if (field != 'birth date' && field != 'gender') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Update $field'),
              content: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: "Enter new $field"),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Update'),
                  onPressed: () async {
                    await updateFunction();
                    await _refreshUserDetails();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        await updateFunction();
      }
    }

    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return RefreshIndicator(
      onRefresh: _refreshUserDetails,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: FutureBuilder<Map<String, String>>(
          future: _getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${snapshot.data?['name'] ?? 'Not available'}',
                            style: TextStyle(fontSize: 20)),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () =>
                              _updateProfile(context, 'username', userId),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (snapshot.data?['photoUrl'] != '')
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(snapshot.data!['photoUrl']!),
                        radius: MediaQuery.of(context).size.width / 5,
                      ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            'Birth Date: ${snapshot.data?['birthDate'] ?? 'Not available'}'),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () =>
                              _updateProfile(context, 'birth date', userId),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            'Gender: ${snapshot.data?['gender'] ?? 'Not available'}'),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () =>
                              _updateProfile(context, 'gender', userId),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // ... logout logic
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
        ),
      ),
    );
  }
}
