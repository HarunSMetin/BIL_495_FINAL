import 'package:flutter/material.dart';
import 'package:gezbot/pages/profile/profile_page.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/components/UserTile.dart';

class FollowingsScreen extends StatefulWidget {
  final String userId;

  const FollowingsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FollowingsScreenState createState() => _FollowingsScreenState();
}

class _FollowingsScreenState extends State<FollowingsScreen> {
  final DatabaseService _databaseService = DatabaseService();

  Future<List<UserModel>> _fetchFollowings() async {
    return _databaseService.GetFollowingsOfUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _fetchFollowings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                UserModel following = snapshot.data![index];
                return UserTile(
                  user: following,
                  currentUserId: widget.userId,
                  databaseService: _databaseService,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(userId: following.id),
                      ),
                    );
                  },
                  showAcceptButton:
                      false, // Set this to false for followings screen
                  onAccept: () {}, // Dummy callback, as we don't need this here
                  canDeleteUser: true, // Set this based on your requirements
                );
              },
            );
          } else {
            return const Center(child: Text('No followings found'));
          }
        },
      ),
    );
  }
}
