import 'package:flutter/material.dart';
import 'package:gezbot/models/hotel.model.dart';
import 'package:gezbot/models/place.model.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/pages/profile/profile_page.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/components/UserTile.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gezbot/pages/chat/chat_page.dart';
import 'package:gezbot/components/HotelWidget.dart';
import 'package:gezbot/components/PlaceWidget.dart';

class TravelPageNew extends StatefulWidget {
  final Travel travel;
  const TravelPageNew({Key? key, required this.travel}) : super(key: key);
  _TravelPageNewState createState() => _TravelPageNewState();
}

class _TravelPageNewState extends State<TravelPageNew> {
  /// Views to display
  late List<Widget>
      views; // Use 'late' because we'll initialize it in initState
  late Future<List<Hotel>> hotelList; // Initialize the future here
  late Future<List<Place>> placeList; // Initialize the future here

  Future<void> refresh() async {
    setState(() {
      hotelList = DatabaseService().getRecomendedHotels(widget.travel.id);
      placeList = DatabaseService().getRecommendedPlaces(widget.travel.id);
    });
  }

  /// The currently selected index of the bar
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize your views list here
    refresh();
    views = [
      const Column(
        children: [
          Text('Flights'),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Color.fromARGB(255, 210, 220, 252),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              onPressed: () async {
                List<Hotel> newHotels = await DatabaseService()
                    .getDifferentHotels(widget.travel.id);
                if (newHotels.isNotEmpty) {
                  print('new hotels found');
                  refresh();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.refresh, color: Colors.black),
                  Text('Give Me Different Hotels'),
                ],
              ),
            ),
          ),
          HotelsTile(widget.travel),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Color.fromARGB(255, 210, 220, 252),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              onPressed: () async {
                refresh();
                List<Place> newPlaces = await DatabaseService()
                    .getDifferentPlaces(widget.travel.id);
                if (newPlaces.isNotEmpty) {
                  print('new places found');
                  refresh();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.refresh, color: Colors.black),
                  Text('Give Me Different Places'),
                ],
              ),
            ),
          ),
          PlacesTile(widget.travel),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MembersTile(widget.travel),
          const SizedBox(height: 20),
          Center(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(travelId: widget.travel.id)),
                    );
                  },
                  child: const Text('Chat about this travel'),
                );
              },
            ),
          ),
        ],
      ),
      // Now it's safe to call MembersTile
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// You can use an AppBar if you want to
      appBar: AppBar(
        title:
            const Text('Travel Details', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 79, 159, 190),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 79, 159, 190),
                Color.fromARGB(255, 4, 44, 77),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      // The row is needed to display the current view
      body: Row(
        children: [
          /// Pretty similar to the BottomNavigationBar!
          SideNavigationBar(
            expandable: true,
            initiallyExpanded: false,
            theme: SideNavigationBarTheme(
              backgroundColor: Color.fromARGB(255, 79, 159, 190),
              togglerTheme: const SideNavigationBarTogglerTheme(
                expandIconColor: Colors.white,
                shrinkIconColor: Colors.white,
              ),
              itemTheme: SideNavigationBarItemTheme(
                  selectedItemColor: Colors.white,
                  selectedBackgroundColor: Colors.white24,
                  unselectedItemColor: Colors.white30),
              dividerTheme: SideNavigationBarDividerTheme.standard(),
            ),
            selectedIndex: selectedIndex,
            items: const [
              SideNavigationBarItem(
                icon: Icons.flight,
                label: 'Flights',
              ),
              SideNavigationBarItem(
                icon: Icons.hotel,
                label: 'Hotels',
              ),
              SideNavigationBarItem(
                icon: Icons.place,
                label: 'Places',
              ),
              SideNavigationBarItem(
                icon: Icons.people,
                label: 'Members',
              ),
            ],
            onTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          /// Make it take the rest of the available width
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: views.elementAt(selectedIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget HotelsTile(Travel travel) {
    return ExpansionTile(
      initiallyExpanded: true,
      iconColor: const Color.fromARGB(255, 4, 44, 77),
      title: const Text("Recommended Hotels",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: <Widget>[
        FutureBuilder(
            future: hotelList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                if ((snapshot.data as List<Hotel>).isEmpty) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'Travel Is Creating Wait A Moment... (it takes a while)'),
                      SizedBox(height: 20),
                      CircularProgressIndicator(color: Colors.blue),
                      SizedBox(height: 20),
                    ],
                  );
                } else {
                  List<Hotel> hotels = snapshot.data as List<Hotel>;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: hotels.length,
                    itemBuilder: (context, index) {
                      Hotel hotel = hotels[index];
                      return HotelWidget(hotel: hotel);
                    },
                  );
                }
              } else {
                return const Text('No hotels found for this travel');
              }
            }),
      ],
    );
  }

  Widget PlacesTile(Travel travel) {
    return ExpansionTile(
      initiallyExpanded: true,
      iconColor: const Color.fromARGB(255, 4, 44, 77),
      title: const Text("Places",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: <Widget>[
        FutureBuilder(
            future: placeList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                if ((snapshot.data as List<Place>).isEmpty) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'Travel Is Creating Wait A Moment... (it takes a while)'),
                      SizedBox(height: 20),
                      CircularProgressIndicator(color: Colors.blue),
                      SizedBox(height: 20),
                    ],
                  );
                } else {
                  List<Place> places = snapshot.data as List<Place>;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      Place place = places[index];
                      return PlaceWidget(place: place);
                    },
                  );
                }
              } else {
                return const Text(
                    'Travel ERROR : No places found for this travel');
              }
            }),
      ],
    );
  }

  Widget MembersTile(Travel travel) {
    Future<List<UserModel>> fetchMemberDetails() async {
      List<UserModel> members = [];
      for (String memberId in travel.members) {
        UserModel user = await UserService().fetchUserDetails(memberId);
        members.add(user);
      }
      return members;
    }

    Future<String> _fetchUID() async {
      return (await SharedPreferences.getInstance()).getString('uid') ?? '';
    }

    return ExpansionTile(
      initiallyExpanded: true,
      iconColor: const Color.fromARGB(255, 4, 44, 77),
      title: const Text("Members",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: <Widget>[
        FutureBuilder<List<UserModel>>(
          future: fetchMemberDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
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
                    future: _fetchUID(),
                    builder: (context, uidSnapshot) {
                      if (uidSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (uidSnapshot.hasError) {
                        return Text('Error: ${uidSnapshot.error}');
                      } else if (uidSnapshot.hasData) {
                        bool canDelete = uidSnapshot.data == travel.creatorId;
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
                                builder: (context) => ProfilePage(
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
    );
  }
}
