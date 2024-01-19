import 'package:flutter/material.dart';
import 'package:gezbot/pages/profile/edit_profile_page.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/services/user_service.dart';

class ProfileActionButtons extends StatefulWidget {
  final String userId;
  final String viewerId;

  ProfileActionButtons({
    Key? key,
    required this.userId,
    required this.viewerId,
  }) : super(key: key);

  @override
  State<ProfileActionButtons> createState() => _ProfileActionButtonsState();
}

class _ProfileActionButtonsState extends State<ProfileActionButtons> {
  DatabaseService _databaseService = DatabaseService();
  UserService _userService = UserService();
  String relationshipStatus = 'none';

  @override
  void initState() {
    super.initState();
    _fetchRelationshipStatus();
  }

  void _fetchRelationshipStatus() async {
    String status = await _userService.checkRelationshipStatus(
        widget.viewerId, widget.userId);
    print(status);
    setState(() {
      relationshipStatus = status;
    });
  }

  void _handleActionButtonPress() async {
    if (widget.userId != widget.viewerId) {
      if (relationshipStatus == 'none' ||
          relationshipStatus == 'cancelled' ||
          relationshipStatus == 'rejected') {
        // Send friend request
        String documentId = await _databaseService.SendFriendRequest(
            widget.viewerId, widget.userId);
        if (documentId.isNotEmpty) {
          setState(() {
            relationshipStatus = 'pending';
          });
        }
      } else if (relationshipStatus == 'pending') {
        await _databaseService.CancelFriendRequest(
            widget.viewerId, widget.userId);
        setState(() {
          relationshipStatus = 'none';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (widget.userId != widget.viewerId)
            _buildActionButton(
              context,
              text: _getActionButtonText(),
              onPressed: _handleActionButtonPress,
            ),
          if (widget.userId == widget.viewerId)
            _buildActionButton(
              context,
              text:
                  widget.userId == widget.viewerId ? 'Edit Profile' : 'Message',
              onPressed: () {
                if (widget.userId == widget.viewerId) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfilePage()),
                  );
                } else {
                  // Implement message functionality
                }
              },
            ),
          _buildActionButton(
            context,
            text: 'Share Profile',
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
    );
  }

  String _getActionButtonText() {
    switch (relationshipStatus) {
      case 'pending':
        return 'Request Pending';
      case 'accepted':
        return 'UnFollow';
      default:
        return 'Follow';
    }
  }

  Widget _buildActionButton(BuildContext context,
      {required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
