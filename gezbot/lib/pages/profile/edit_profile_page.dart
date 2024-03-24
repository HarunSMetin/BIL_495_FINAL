import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gezbot/pages/login_screen/components/center_widget/center_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
// Instance of UserService
  late Future<Map<String, String>> userDetailsFuture;

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
                  decoration: const InputDecoration(labelText: 'Username: '),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: null,
                  decoration: const InputDecoration(labelText: 'Age: '),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: null,
                  decoration: const InputDecoration(labelText: 'Gender: '),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () {
                    // TODO: #57 Implement logic to save edited profile
                    _refreshUserDetails();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
