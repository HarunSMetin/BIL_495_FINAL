import 'package:flutter/material.dart';
import 'package:gezbot/pages/travel/travel_page.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/pages/home/centered_mini_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncompleteTravel extends StatefulWidget {
  final Future<Travel?> lastIncompleteTravel;
  double top;
  double height;
  double width;

  IncompleteTravel({super.key, required this.lastIncompleteTravel, required this.top, required this.height, required this.width});

  @override
  IncompleteTravelState createState() => IncompleteTravelState();
}

class IncompleteTravelState extends State<IncompleteTravel> {
  late final prefs;

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  void getPrefs() async
  {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Travel?>(
      future: widget.lastIncompleteTravel,
      builder: (context, snapshot) {
        Travel? lastTravel = snapshot.data;
        if (lastTravel != null) {
          return Padding(
            padding: EdgeInsets.only(top: widget.top),
            child: Container(
              height: widget.height,
              width: widget.width,
              child: Column(
                children: [
                  CenteredMiniTitle(title: 'Your incomplete travels', top: widget.top, width: widget.width),
                  Container(
                    width: widget.width * 0.7, // Adjust the width as needed (e.g., 80% of screen width)
                    child: const Text(
                      'Apparently, you didn\'t complete creating your last travel.',
                      textAlign: TextAlign.center, // Center the text within the container
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () { //if tapped, travel page is loaded
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TravelsScreen(userId: prefs.getString('uid'))),
                      );
                    },
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          );
        } 
        else {
          return Container();
        }
      }
    );
  }
}