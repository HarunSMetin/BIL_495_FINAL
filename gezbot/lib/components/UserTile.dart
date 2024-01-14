import 'package:flutter/material.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/services/database_service.dart';

class UserTile extends StatefulWidget {
  final UserModel user;
  final String currentUserId;
  final DatabaseService databaseService;
  final VoidCallback onTap;

  UserTile({
    Key? key,
    required this.user,
    required this.currentUserId,
    required this.databaseService,
    required this.onTap,
  }) : super(key: key);

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: ListTile(
        title: Text(
          widget.user.userName,
          overflow: TextOverflow.ellipsis,
        ),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.user.photoUrl),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () async {
            await widget.databaseService
                .removeFollowing(widget.currentUserId, widget.user.id);
          },
        ),
      ),
    );
  }
}
