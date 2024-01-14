import 'package:flutter/material.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/pages/profile/screens/followers_screen.dart';
import 'package:gezbot/pages/profile/screens/followings_screen.dart';
import 'package:gezbot/pages/travel/travel_page.dart';
import 'package:gezbot/services/database_service.dart';

class UserStats extends StatefulWidget {
  final UserModel user;

  UserStats({Key? key, required this.user}) : super(key: key);

  @override
  State<UserStats> createState() => _UserStatsState();
}

class _UserStatsState extends State<UserStats> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _databaseService.GetUserSummary(widget.user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error fetching data');
        } else if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                    context, "Travels", snapshot.data!['travels'].toString()),
                _buildStatItem(context, "Followers",
                    snapshot.data!['acceptedReceived'].toString()),
                _buildStatItem(context, "Following",
                    snapshot.data!['acceptedSent'].toString()),
              ],
            ),
          );
        } else {
          return const Text('No data available');
        }
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return GestureDetector(
      onTap: () {
        if (label == "Travels") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TravelsScreen()),
          );
        }
        if (label == "Followers") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FollowersScreen(userId: widget.user.id)),
          );
        }
        if (label == "Following") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FollowingsScreen(userId: widget.user.id)),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
