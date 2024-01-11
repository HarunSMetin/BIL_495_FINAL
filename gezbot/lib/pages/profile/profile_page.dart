import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gezbot/services/user_service.dart'; // Import UserService

//hello

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService(); // Instance of UserService
  late Future<Map<String, String>> userDetailsFuture;
  XFile? _imageFile;
  @override
  void initState() {
    super.initState();
    userDetailsFuture = _getUserDetails();
  }

  int _calculateAge(String birthDateString) {
    if (birthDateString == 'Not available') {
      return -1; // Indicates age is not available
    }

    DateTime birthDate = DateTime.parse(birthDateString);
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (birthDate.month > currentDate.month ||
        (birthDate.month == currentDate.month &&
            birthDate.day > currentDate.day)) {
      age--;
    }

    return age;
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

    void logout() async {
      final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId:
              "1027985224810-jeioofe75dtanigd4r1vtgv4v4glemis.apps.googleusercontent.com");
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    }

    void _updateProfile(
        BuildContext context, String field, String userId) async {
      TextEditingController _controller = TextEditingController();
      late Future<void> Function() updateFunction;

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

    Future<void> _pickImage() async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() => _imageFile = pickedFile);

        try {
          await _userService.updateUserProfilePhoto(
            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
            imagePath: _imageFile!.path,
            showErrorDialog: _showErrorDialog,
          );
          // Refresh the profile
          await _refreshUserDetails();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image Updated Successfully')));
        } catch (e) {
          _showErrorDialog('Failed to update image: ${e.toString()}');
        }
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
              return SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width / 4,
                            MediaQuery.of(context).size.height / 5,
                            MediaQuery.of(context).size.width / 4,
                            0), // Adjust the value as needed
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                '${snapshot.data?['name'] ?? 'Not available'}',
                                style: TextStyle(fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () =>
                                  _updateProfile(context, 'username', userId),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      if (snapshot.data?['photoUrl'] != '')
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(snapshot.data!['photoUrl']!),
                              radius: MediaQuery.of(context).size.width / 5,
                            ),
                            IconButton(
                              icon: Icon(Icons.camera_alt),
                              onPressed: _pickImage,
                              color: Theme.of(context).primaryColor,
                              iconSize: 30,
                            ),
                          ],
                        ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Age: ${_calculateAge(snapshot.data?['birthDate'] ?? 'Not available') != -1 ? _calculateAge(snapshot.data?['birthDate'] ?? 'Not available').toString() : 'Not available'}',
                          ),
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
                        onPressed: logout,
                        child: Text('Logout'),
                      ),
                    ],
                  ),
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
