import 'package:flutter/material.dart';
import 'package:gezbot/pages/profile/widgets/ProfileHeader.dart';
import 'package:gezbot/pages/profile/widgets/StatWidget.dart';
import 'package:gezbot/pages/profile/widgets/profile_action_buttons.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/services/user_service.dart';
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

  @override
  void initState() {
    super.initState();
    userDetailsFuture = _userService.fetchUserDetails(widget.userId);
  }

  Future<UserModel> _fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String currentUserId = prefs.getString('uid') ?? '';
    return _userService.fetchUserDetails(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          UserStats(user: user),
          ProfileActionButtons(),
        ],
      ),
    );
  }
}
