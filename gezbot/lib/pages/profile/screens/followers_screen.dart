import 'package:flutter/material.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/models/user.model.dart';

class FollowersScreen extends StatefulWidget {
  final String userId;

  const FollowersScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final DatabaseService _databaseService = DatabaseService();

  Future<List<UserModel>> _fetchFollowers() async {
    return _databaseService.GetFollowersOfUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _fetchFollowers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                UserModel follower = snapshot.data![index];
                return ListTile(
                  title: Text(
                    follower.userName,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(follower.photoUrl),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await _databaseService.removeFollower(
                          widget.userId, follower.id);
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No followers found'));
          }
        },
      ),
    );
  }
}
