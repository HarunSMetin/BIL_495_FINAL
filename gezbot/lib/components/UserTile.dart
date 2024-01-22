import 'package:flutter/material.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/services/database_service.dart';

class UserTile extends StatefulWidget {
  final UserModel user;
  final String currentUserId;
  final DatabaseService databaseService;
  final VoidCallback onTap;
  final bool canDeleteUser;
  final bool showAcceptButton;
  final VoidCallback onAccept;
  final bool isFollowersPage;

  UserTile({
    Key? key,
    required this.user,
    required this.currentUserId,
    required this.databaseService,
    required this.onTap,
    this.canDeleteUser = false,
    this.showAcceptButton = false,
    required this.onAccept,
    this.isFollowersPage = false,
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
        trailing: widget.showAcceptButton
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    child: Text('Accept'),
                    onPressed: widget.onAccept,
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    child: Text('Decline'),
                    onPressed: onDecline,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                  ),
                ],
              )
            : (widget.canDeleteUser
                ? IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () async {
                      if (!widget.isFollowersPage) {
                        await widget.databaseService.CancelFriendRequest(
                            widget.currentUserId, widget.user.id);
                      } else {
                        await widget.databaseService.CancelFriendRequest(
                            widget.user.id, widget.currentUserId);
                      }
                    },
                  )
                : null),
      ),
    );
  }

  void onDecline() async {
    await widget.databaseService
        .DeclineFriendRequest(widget.user.id, widget.currentUserId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Declined ${widget.user.userName}'),
      ),
    );
  }
}
