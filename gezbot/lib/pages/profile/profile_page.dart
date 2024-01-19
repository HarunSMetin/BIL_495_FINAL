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

  Future<UserModel> _fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String sessionUserId = prefs.getString('uid') ?? '';
    return _userService.fetchUserDetails(sessionUserId);
  }

  void _initializeViewerID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _viewerID = prefs.getString('uid') ?? '';
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final GoogleSignIn _googleSignIn = GoogleSignIn(
        clientId:
            "1027985224810-jeioofe75dtanigd4r1vtgv4v4glemis.apps.googleusercontent.com");
    await FirebaseAuth.instance.signOut();
    await prefs.clear();
    await _googleSignIn.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _navigateToNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => NotificationsWidget()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (widget.userId == _viewerID)
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: _navigateToNotifications,
            ),
          if (widget.userId == _viewerID)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: FutureBuilder<UserModel>(
        future: userDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            return _buildProfilePage(snapshot.data!);
          } else {
            return const Text('No data available');
          }
        },
      ),
    );
  }

  Widget _buildProfilePage(UserModel user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          UserProfileHeader(user: user),
          UserStats(userId: _viewerID, user: user),
          ProfileActionButtons(userId: widget.userId, viewerId: _viewerID),
        ],
      ),
    );
  }
}
