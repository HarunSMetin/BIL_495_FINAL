import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gezbot/pages/profile/widgets/NotificationsPage.dart';
import 'package:gezbot/pages/profile/widgets/ProfileHeader.dart';
import 'package:gezbot/pages/profile/widgets/StatWidget.dart';
import 'package:gezbot/pages/profile/widgets/profile_action_buttons.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/services/user_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserModel> userDetailsFuture;
  final UserService _userService = UserService();
  String _viewerID = 'empty';

  @override
  void initState() {
    super.initState();
    _initializeViewerID();
    userDetailsFuture = _userService.fetchUserDetails(widget.userId);
  }

  void _initializeViewerID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _viewerID = prefs.getString('uid') ?? '';
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final GoogleSignIn googleSignIn = GoogleSignIn(clientId: "YOUR_CLIENT_ID");
    await FirebaseAuth.instance.signOut();
    await prefs.clear();
    await googleSignIn.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _navigateToNotifications() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const NotificationsWidget()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 174, 169, 248),
                Color.fromARGB(255, 183, 217, 245),
              ],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (widget.userId == _viewerID)
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: _navigateToNotifications,
            ),
          if (widget.userId == _viewerID)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue.shade100, Colors.green.shade100],
          ),
        ),
        child: FutureBuilder<UserModel>(
          future: userDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return _buildProfilePage(snapshot.data!);
            } else {
              return const Text('No data available');
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfilePage(UserModel user) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              UserProfileHeader(user: user), // User profile header
              UserStats(userId: _viewerID, user: user), // User stats
              const SizedBox(
                  height:
                      80), // Add some space before the action buttons at the bottom
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child:
              ProfileActionButtons(userId: widget.userId, viewerId: _viewerID),
        ),
      ],
    );
  }
}
