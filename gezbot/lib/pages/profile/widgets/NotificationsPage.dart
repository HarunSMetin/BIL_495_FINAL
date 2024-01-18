import 'package:flutter/material.dart';
import 'package:gezbot/services/database_service.dart';

class NotificationsWidget extends StatefulWidget {
  final String userId;

  NotificationsWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _NotificationsWidgetState createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  Map<String, dynamic> pendingRequests = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  void _fetchPendingRequests() async {
    pendingRequests = await DatabaseService()
        .GetPendingFriendRequestsRecivedByUser(widget.userId);
    setState(() {
      isLoading = false;
    });
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
            ...pendingRequests.entries
                .map((entry) => ListTile(
                      title: Text('Request from ${entry.value['senderId']}'),
                      subtitle: Text('Sent at: ${entry.value['sentAt']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          DatabaseService().AcceptFriendRequest(entry.key);
                          setState(() {
                            pendingRequests.remove(entry.key);
                          });
                        },
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
