import 'package:flutter/material.dart';
import 'package:gezbot/components/UserTile.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/pages/profile/profile_page.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationsWidgetState createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  Map<String, dynamic> pendingRequests = {};
  bool isLoading = true;
  String userId = '';

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  void _initializeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('uid') ?? '';
    _fetchPendingRequests();
  }

  void _fetchPendingRequests() async {
    if (userId.isNotEmpty) {
      pendingRequests =
          await DatabaseService().getPendingFriendRequestsRecivedByUser(userId);
      setState(() {
        isLoading = false;
      });
    } else {
      // Handle the scenario where the user ID is not found
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<UserModel> _fetchUserDetails(String userId) async {
    return await UserService().fetchUserDetails(userId);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pending Requests', style: TextStyle(fontSize: 18.0)),
            ...pendingRequests.entries.map((entry) {
              return FutureBuilder<UserModel>(
                future: _fetchUserDetails(entry.value['senderId']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return UserTile(
                      user: snapshot.data!,
                      currentUserId: userId,
                      databaseService: DatabaseService(),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(userId: snapshot.data!.id),
                          ),
                        );
                      },
                      showAcceptButton: true,
                      onAccept: () async {
                        await DatabaseService().acceptFriendRequest(entry.key);
                        setState(() {
                          pendingRequests.remove(entry.key);
                        });
                      },
                    );
                  } else {
                    return const Text('No user data available');
                  }
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
