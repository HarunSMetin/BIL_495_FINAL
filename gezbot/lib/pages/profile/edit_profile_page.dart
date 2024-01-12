import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gezbot/services/user_service.dart'; // Import UserService

import 'package:gezbot/pages/login_screen/components/center_widget/center_widget.dart';
import 'package:gezbot/pages/login_screen/components/center_widget/center_widget_clipper.dart';
import 'package:gezbot/pages/login_screen/components/center_widget/center_widget_painter.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UserService _userService = UserService(); // Instance of UserService
  late Future<Map<String, String>> userDetailsFuture;
  XFile? _imageFile;

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
            SnackBar(content: Text('Image Updated Successfully')));
      } catch (e) {
        _showErrorDialog('Failed to update image: ${e.toString()}');
      }
    }
  }

  void _updateProfile(BuildContext context, String field, String userId) async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CenterWidget(
          size: MediaQuery.of(context).size,
        ),
        Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: null,
                  decoration: InputDecoration(labelText: 'Username: '),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: null,
                  decoration: InputDecoration(labelText: 'Age: '),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: null,
                  decoration: InputDecoration(labelText: 'Gender: '),
                ),
                SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement logic to save edited profile
                    _refreshUserDetails();
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
