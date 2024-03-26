import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gezbot/models/hotel.model.dart';
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
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TravelPageNew extends StatefulWidget {
  final Travel travel;
  const TravelPageNew({Key? key, required this.travel}) : super(key: key);
  _TravelPageNewState createState() => _TravelPageNewState();
}

class _TravelPageNewState extends State<TravelPageNew> {
  /// Views to display
  late List<Widget>
      views; // Use 'late' because we'll initialize it in initState

  /// The currently selected index of the bar
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize your views list here
    views = [
      Center(
        child: Text('Flights'),
      ),
      Center(
        child: HotelsTile(widget.travel),
      ),
      Center(
        child: PlaceWidget(
          place: PlaceDetails(
            name: 'Hotel Mostar',
            rating: 3.8,
            userRatingsTotal: 128,
            icon:
                'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/lodging-71.png',
            location: LatLng(39.936338, 32.8566689),
          ),
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: views.elementAt(selectedIndex),
          )
        ],
      ),
    );
  }

  Widget HotelsTile(Travel travel) {
    String formatPriceString(String input) {
      List<String> words = input.split('_');
      String formattedString = words
          .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
          .join(' ');

      return formattedString;
    }

    List<String> cats = [];
    for (String cat in DatabaseService().categories) {
      cats.add(formatPriceString(cat));
    }

    List<ExpansionTile> tiles = [];
    for (String cat in cats) {
      tiles.add(
        ExpansionTile(
          initiallyExpanded: true,
          backgroundColor: Colors.blue[100],
          iconColor: const Color.fromARGB(255, 4, 44, 77),
          title: Text("$cat Hotels",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          children: <Widget>[
            FutureBuilder(
                future: DatabaseService().getRecomendedHotels(travel.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    if ((snapshot.data as Map<String, Hotel>).isEmpty) {
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
                      Map<String, Hotel> hotels =
                          snapshot.data as Map<String, Hotel>;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: hotels.length,
                        itemBuilder: (context, index) {
                          Hotel hotel = hotels.values.elementAt(index);
                          return HotelWidget(hotel: hotel);
                        },
                      );
                    }
                  } else {
                    return const Text(
                        'Travel ERROR : No hotels found for this travel');
                  }
                }),
          ],
        ),
      );
    }
    return ListView(
      children: tiles,
    );
  }

/*
  Widget Places(Travel travel) {
    ExpansionTile(
      initiallyExpanded: true,
      backgroundColor: Colors.blue[100],
      iconColor: const Color.fromARGB(255, 4, 44, 77),
      title: const Text("Places",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: <Widget>[
        FutureBuilder(
            future: DatabaseService().getRecomendedPlaces(travel.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                if ((snapshot.data as Map<String, Hotel>).isEmpty) {
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
                  Map<String, Hotel> hotels =
                      snapshot.data as Map<String, Hotel>;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: hotels.length,
                    itemBuilder: (context, index) {
                      Hotel hotel = hotels.values.elementAt(index);
                      return HotelWidget(hotel: hotel);
                    },
                  );
                }
              } else {
                return const Text(
                    'Travel ERROR : No hotels found for this travel');
              }
            }),
      ],
    );
  }
 */
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
      backgroundColor: Colors.blue[100],
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
