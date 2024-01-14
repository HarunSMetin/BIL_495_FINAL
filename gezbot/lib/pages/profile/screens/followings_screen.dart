import 'package:flutter/material.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/models/user.model.dart';

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

  void _unfollowUser(String followingId) {
    // TODO: Implement the functionality to unfollow a user
    print('Unfollow user: $followingId');
    // After unfollowing, you might want to refresh the list of followings
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
                return ListTile(
                  title: Text(
                    following.userName,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(following.photoUrl),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () async {
                      await _databaseService.removeFollowing(
                          widget.userId, following.id);
                    },
                  ),
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
