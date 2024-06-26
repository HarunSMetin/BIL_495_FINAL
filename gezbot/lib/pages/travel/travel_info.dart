import 'package:auto_size_text/auto_size_text.dart';
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

  Future<List<Place>?> _initializePlaces() async {
    placeList = await DatabaseService().getRecommendedPlaces(widget.travel.id);
    return placeList;
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

    return FutureBuilder(
        future: _initializePlaces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the places to initialize, show a loading indicator
            return Scaffold(
              appBar: AppBar(title: Text(widget.travel.name)),
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            // If there's an error during initialization, show an error message
            return Scaffold(
              appBar: AppBar(title: Text(widget.travel.name)),
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            // If initialization is successful, build the page content
            LatLng initialPosition = LatLng(0, 0);
            if (placeList != null && placeList!.isNotEmpty) {
              initialPosition = LatLng(
                placeList![0].geometry?.location?.lat ?? 0,
                placeList![0].geometry?.location?.lng ?? 0,
              );
            }
            List<LatLng> pointsToMark = [];
            for (Place place in placeList!) {
              pointsToMark.add(LatLng(
                place.geometry?.location?.lat ?? 0,
                place.geometry?.location?.lng ?? 0,
              ));
            }

            return Scaffold(
              appBar: AppBar(
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 174, 169, 248),
                          Color.fromARGB(255, 183, 217, 245),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                  ),
                  title: Text(widget.travel.name)),
              body: Container(
                width: queryData.size.width,
                height: queryData.size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.blue.shade100, Colors.green.shade100],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const Text("Travel Ticket",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
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
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              ticketDetail("Name", widget.travel.name),
                              ticketDetail(
                                  "Departure Date",
                                  widget.travel.departureDate
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]),
                              ticketDetail(
                                  "Return Date",
                                  widget.travel.returnDate
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]),
                              ticketDetail("Desired Destination",
                                  widget.travel.desiredDestination),
                              const SizedBox(height: 10),
                              FutureBuilder(
                                future: DatabaseService()
                                    .getSelectedHotelsMostRated(
                                        widget.travel.id),
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
                                },
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: queryData.size.height / 3,
                                child: MapWidget(
                                  initialPosition: initialPosition,
                                  pointsToMark: pointsToMark,
                                ),
                              ),
                              const SizedBox(height: 5),
                              ExpansionTile(
                                initiallyExpanded: true,
                                title: const Text("Members",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
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
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: snapshot.data!.length,
                                          itemBuilder: (context, index) {
                                            UserModel member =
                                                snapshot.data![index];
                                            return FutureBuilder<String>(
                                              future: _uidFuture,
                                              builder: (context, uidSnapshot) {
                                                if (uidSnapshot
                                                        .connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const CircularProgressIndicator();
                                                } else if (uidSnapshot
                                                    .hasError) {
                                                  return Text(
                                                      'Error: ${uidSnapshot.error}');
                                                } else if (uidSnapshot
                                                    .hasData) {
                                                  bool canDelete = uidSnapshot
                                                          .data ==
                                                      widget.travel.creatorId;
                                                  return UserTile(
                                                    user: member,
                                                    currentUserId:
                                                        uidSnapshot.data!,
                                                    showAcceptButton: false,
                                                    onAccept: () {},
                                                    canDeleteUser: canDelete,
                                                    databaseService:
                                                        DatabaseService(),
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
                                                  return const Text(
                                                      'UID not found');
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () =>
                              _openChatScreen(context, widget.travel.id),
                          child: const Text('Chat about this travel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
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
              child: AutoSizeText(
                value,
                softWrap: false,
                overflow: TextOverflow.clip,
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
