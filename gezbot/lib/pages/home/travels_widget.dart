import 'package:flutter/material.dart';
import 'package:gezbot/pages/home/incomplete_travel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/pages/travel/travel_page.dart';
import 'package:gezbot/pages/home/welcome_widget.dart';
import 'package:gezbot/pages/travel/travel_info.dart';
import 'package:gezbot/pages/home/centered_mini_title.dart';

// ignore: must_be_immutable
class TravelsWidget extends StatefulWidget {
  String userId;
  TravelsWidget({super.key, required this.userId});

  @override
  TravelsWidgetState createState() => TravelsWidgetState();
}

class TravelsWidgetState extends State<TravelsWidget> {
  final DatabaseService dbService = DatabaseService();
  Future<List<Travel>>? travelsFuture;
  late Future<Travel?> lastIncompleteTravelFuture;
  late Travel? lastIncompleteTravel;
  String travelInfo = "";

  bool loaded = false;
  bool hasCompleteTravels = false;
  int currentTravelIndex = 0;
  int incompleteTravels = 0;
  int numOfTravels = 0;
  // ignore: prefer_typing_uninitialized_variables
  late final prefs;

  @override
  void initState() {
    super.initState();
    _fetchTravels();
    travelsFuture = _fetchFutureTravels();
    lastIncompleteTravelFuture = fetchLastIncompleteTravel();

  }

  Future<void> _fetchTravels() async {
    prefs = await SharedPreferences.getInstance();
    Travel? lastTravel = await dbService.getLastNotCompletedTravelOfUser(widget.userId);
    List<Travel> travelsData =
        await dbService.getAllTravelsOfUserByShowStatus(widget.userId);

    setState(() {
      for (Travel travel in travelsData) //can be in database
      {
        if (!travel.isCompleted)
        {
          incompleteTravels++;
        }
      }
      
      lastIncompleteTravel = lastTravel;
      loaded = true;
      numOfTravels = travelsData.length;

      if (numOfTravels != incompleteTravels)
      {
        hasCompleteTravels = true;
      }

      if (travelsData.isNotEmpty)
      {
        travelInfo = 'Upcoming travel: ${travelsData.elementAt(currentTravelIndex).name} in ${travelsData.elementAt(currentTravelIndex).departureDate}.';
      }
    });
  }

  Future<List<Travel>> _fetchFutureTravels() async {
    List<Travel> travelsData = await dbService.getAllTravelsOfUserByShowStatus(widget.userId);
    return travelsData;
  }

  Future<Travel?> fetchLastIncompleteTravel() async {
    Travel? lastTravel = await dbService.getLastNotCompletedTravelOfUser(widget.userId);
    return lastTravel;
  }

  void goToNextTravel(List<Travel> travels) {
    if (currentTravelIndex < travels.length - 1) {
      setState(() {
        currentTravelIndex++;
      });
    }
  }

  void goToPreviousTravel() {
    if (currentTravelIndex > 0) {
      setState(() {
        currentTravelIndex--;
      });
    }
  }

  void updateCurrentTravel(List<Travel> travels) {
    setState(() {
      travelInfo = 'Upcoming travel: ${travels.elementAt(currentTravelIndex).name} in ${travels.elementAt(currentTravelIndex).departureDate}.';
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return loaded 
      ? Stack(
        children: [
          IncompleteTravel(lastIncompleteTravel: lastIncompleteTravelFuture, top: screenSize.height/3, height: screenSize.height, width: screenSize.width,),
          Container(height: screenSize.height/10,),
          hasCompleteTravels
            ? Positioned(
              top: screenSize.height*7 / 40,
              left: screenSize.width / 20,
              right: screenSize.width / 20,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.0),
                height: screenSize.height / 5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: (currentTravelIndex > 0) ? //display left arrow
                        GestureDetector(
                          onTap: () {
                            travelsFuture!.then((travels) {
                              goToPreviousTravel();
                              updateCurrentTravel(travels);
                            });
                          },
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          ),
                        )
                      : Container(), //puts empty container instead of arrow
                    ),
                    Positioned(
                      right: 0,
                      child: (currentTravelIndex < numOfTravels-1) ? //display right arrow
                        GestureDetector(
                          onTap: () {
                            travelsFuture!.then((travels) {
                              goToNextTravel(travels);
                              updateCurrentTravel(travels);
                            });
                          },
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                        )
                        : Container(),
                    ),
                    Positioned(
                      left: screenSize.width / 7,
                      right: screenSize.width / 7,
                      top: 0, // Adjust the top position of the text
                      child: Text(
                        travelInfo,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned( //goes to that travel page
                      bottom: screenSize.height/20,
                      child: ElevatedButton(
                        onPressed: () {
                          travelsFuture!.then((travels) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TravelInformation(travel: travels.elementAt(currentTravelIndex)),
                              ),
                            );
                          });
                        },
                        child: const Text('Get details'),
                      ),
                    ),
                  ],
                ),
              ),
            )
            : Padding(
              padding: EdgeInsets.only(top: screenSize.height/10), //Adjusting the distance to top of the screen
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, //Centering arrows horizontally
                  children: [
                    const SizedBox(height: 50),
                    const Text("Don't have a travel plan yet?"),
                    const SizedBox(height: 15), //Adding extra spacing between button and text
                    ElevatedButton(
                      onPressed: () { //if tapped, travel page is loaded
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TravelsScreen(userId: prefs.getString('uid'))),
                        );
                      },
                      child: const Text('Create Travel'),
                    ),
                  ],
                ),
              ),
            ),
            CenteredMiniTitle(title: 'Your travels', top: screenSize.height / 10, width: screenSize.width),
            Container( //when this is absent, welcome widget makes underlying widgets disappear
              width: screenSize.width,
              height: screenSize.height,
            ),
            const WelcomeWidget(),
        ]
      ) 
      : const Center(
        child: CircularProgressIndicator(), //If it's not loading
      );
  }
}