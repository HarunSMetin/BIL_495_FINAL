import 'package:flutter/material.dart';
import 'package:gezbot/pages/profile/edit_profile_page.dart';

class ProfileActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context,
            text: 'Edit Profile',
            onPressed: () {
              // Implement navigation to the Edit Profile page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
          ),
          _buildActionButton(
            context,
            text: 'Share Profile',
            onPressed: () {
              // Implement Share Profile functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
