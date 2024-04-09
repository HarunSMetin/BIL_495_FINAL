import 'package:flutter/material.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/pages/profile/screens/followers_screen.dart';
import 'package:gezbot/pages/profile/screens/followings_screen.dart';
import 'package:gezbot/pages/travel/travel_page.dart';
import 'package:gezbot/services/database_service.dart';

class UserStats extends StatefulWidget {
  final UserModel user;
  final String userId;

  const UserStats({Key? key, required this.user, required this.userId})
      : super(key: key);

  @override
  State<UserStats> createState() => _UserStatsState();
}

class _UserStatsState extends State<UserStats> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _databaseService.getUserSummary(widget.user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching data'));
        } else if (snapshot.hasData) {
          return Container(
            //color: Colors.white, // White background
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
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return GestureDetector(
      onTap: () => _navigateToScreen(context, label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(
                  0.7), // Slightly subdued text color for modern feel
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey
                  .shade600, // Grey color for labels to differentiate from values
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String label) {
    switch (label) {
      case "Travels":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TravelsScreen(
                    userId: widget.user.id, viewerId: widget.userId)));
        break;
      case "Followers":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FollowersScreen(userId: widget.user.id)));
        break;
      case "Following":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FollowingsScreen(userId: widget.user.id)));
        break;
    }
  }
}
