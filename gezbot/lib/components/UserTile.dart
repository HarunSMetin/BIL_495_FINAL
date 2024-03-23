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

  const UserTile({
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
                    onPressed: widget.onAccept,
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onDecline,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Decline'),
                  ),
                ],
              )
            : (widget.canDeleteUser
                ? IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () async {
                      if (!widget.isFollowersPage) {
                        await widget.databaseService.cancelFriendRequest(
                            widget.currentUserId, widget.user.id);
                      } else {
                        await widget.databaseService.cancelFriendRequest(
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
        .declineFriendRequest(widget.user.id, widget.currentUserId);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Declined ${widget.user.userName}'),
      ),
    );
  }
}
