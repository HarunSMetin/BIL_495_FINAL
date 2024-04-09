import 'package:flutter/material.dart';
import 'package:gezbot/components/HotelWidget.dart';
import 'package:gezbot/components/MapWidget.dart';
import 'package:gezbot/components/UserTile.dart';
import 'package:gezbot/models/hotel.model.dart';
import 'package:gezbot/models/place.model.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/pages/chat/chat_page.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/pages/profile/profile_page.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/services/user_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gezbot/pages/travel/travelPage_new.dart';

class TravelInformation extends StatefulWidget {
  final Travel travel;

  const TravelInformation({super.key, required this.travel});

  @override
  State<TravelInformation> createState() => _TravelInformationState();
}

class _TravelInformationState extends State<TravelInformation> {
  late Future<List<UserModel>> _membersFuture;
  final Future<String> _uidFuture = _fetchUID();

  late List<Place>? placeList; // Initialize the future here
  static Future<String> _fetchUID() async {
    return (await SharedPreferences.getInstance()).getString('uid') ?? '';
  }

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMemberDetails();
    _initializePlaces();
  }

  Future<void> _initializePlaces() async {
    placeList = await DatabaseService().getRecommendedPlaces(widget.travel.id);
    setState(() {});
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
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);

    // Check if placeList is null, if it is, show a loading indicator
    if (placeList == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.travel.name)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If placeList is not null, proceed with building the page content
    LatLng initialPosition = LatLng(
        placeList!.isNotEmpty ? placeList![0].geometry?.location?.lat ?? 0 : 0,
        placeList!.isNotEmpty ? placeList![0].geometry?.location?.lng ?? 0 : 0);
    List<LatLng> pointsToMark = [];
    if (placeList!.isNotEmpty) {
      for (Place place in placeList!) {
        pointsToMark.add(LatLng(place.geometry?.location?.lat ?? 0,
            place.geometry?.location?.lng ?? 0));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.travel.name)),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                width: 300,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TravelPageNew(
                            travel: widget.travel,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Travel Details Page',
                      style: TextStyle(fontSize: 16),
                    )),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text("Travel Ticket",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const Divider(),
                      ticketDetail("Name", widget.travel.name),
                      ticketDetail("Departure Date",
                          widget.travel.departureDate.toString()),
                      ticketDetail(
                          "Return Date", widget.travel.returnDate.toString()),
                      ticketDetail("Desired Destination",
                          widget.travel.desiredDestination),
                      const SizedBox(height: 10),
                      FutureBuilder(
                          future:
                              DatabaseService().getFirstHotel(widget.travel.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              Hotel hotel = snapshot.data as Hotel;
                              return HotelWidget(hotel: hotel);
                            } else {
                              return const Text('No hotel found');
                            }
                          }),
                      ExpansionTile(
                        title: const Text("Members",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        children: <Widget>[
                          FutureBuilder<List<UserModel>>(
                            future: _membersFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    UserModel member = snapshot.data![index];
                                    return FutureBuilder<String>(
                                      future: _uidFuture,
                                      builder: (context, uidSnapshot) {
                                        if (uidSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (uidSnapshot.hasError) {
                                          return Text(
                                              'Error: ${uidSnapshot.error}');
                                        } else if (uidSnapshot.hasData) {
                                          bool canDelete = uidSnapshot.data ==
                                              widget.travel.creatorId;
                                          return UserTile(
                                            user: member,
                                            currentUserId: uidSnapshot.data!,
                                            showAcceptButton: false,
                                            onAccept: () {},
                                            canDeleteUser: canDelete,
                                            databaseService: DatabaseService(),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfilePage(
                                                    userId: member.id,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          return const Text('UID not found');
                                        }
                                      },
                                    );
                                  },
                                );
                              } else {
                                return const Text('No members found');
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: queryData.size.height / 3,
                        child: MapWidget(
                          initialPosition: initialPosition,
                          pointsToMark: pointsToMark,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _openChatScreen(context, widget.travel.id),
                  child: const Text('Chat about this travel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ticketDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
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
