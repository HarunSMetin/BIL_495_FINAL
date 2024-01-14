import 'package:flutter/material.dart';
import 'package:gezbot/components/UserTile.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/pages/chat/chat_page.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/pages/profile/profile_page.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelInformation extends StatefulWidget {
  final Travel travel;

  TravelInformation({required this.travel});

  @override
  State<TravelInformation> createState() => _TravelInformationState();
}

class _TravelInformationState extends State<TravelInformation> {
  late Future<List<UserModel>> _membersFuture;
  Future<String> _uidFuture = _fetchUID();
  static Future<String> _fetchUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid') ?? '';
  }

  UserService _userService = UserService();
  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMemberDetails();
  }

  Future<List<UserModel>> _fetchMemberDetails() async {
    List<UserModel> members = [];
    for (String memberId in widget.travel.members) {
      UserModel user = await _userService.fetchUserDetails(memberId);
      members.add(user);
    }
    return members;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.travel.name)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Travel Ticket",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Divider(),
                ticketDetail("Name", widget.travel.name),
                ticketDetail(
                    "Departure Date", widget.travel.departureDate.toString()),
                ticketDetail(
                    "Return Date", widget.travel.returnDate.toString()),
                ticketDetail(
                    "Desired Destination", widget.travel.desiredDestination),
                SizedBox(height: 10),
                Text("Members",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Expanded(
                  child: FutureBuilder<List<UserModel>>(
                    future: _membersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            UserModel member = snapshot.data![index];

                            // Nested FutureBuilder for UID
                            return FutureBuilder<String>(
                              future: _uidFuture,
                              builder: (context, uidSnapshot) {
                                if (uidSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (uidSnapshot.hasError) {
                                  return Text('Error: ${uidSnapshot.error}');
                                } else if (uidSnapshot.hasData) {
                                  return UserTile(
                                    user: member,
                                    currentUserId: uidSnapshot.data!,
                                    databaseService: DatabaseService(),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProfilePage(
                                            userId: member.id,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return Text('UID not found');
                                }
                              },
                            );
                          },
                        );
                      } else {
                        return Text('No members found');
                      }
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _openChatScreen(context, widget.travel.id),
                  child: Text('Chat about this travel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget ticketDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _openChatScreen(BuildContext context, String travelId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(travelId: travelId)),
    );
  }
}
