import 'package:flutter/material.dart';
import 'package:gezbot/pages/travel/travel_page.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/pages/home/centered_mini_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncompleteTravel extends StatefulWidget {
  final Future<Travel?> lastIncompleteTravel;
  final double top;
  final double height;
  final double width;

  IncompleteTravel(
      {Key? key,
      required this.lastIncompleteTravel,
      required this.top,
      required this.height,
      required this.width})
      : super(key: key);

  @override
  IncompleteTravelState createState() => IncompleteTravelState();
}

class IncompleteTravelState extends State<IncompleteTravel> {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  void getPrefs() async {
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
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(50),
              ),
              width: widget.width,
              height: widget.height / 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CenteredMiniTitle(
                      title: 'Your incomplete travels',
                      top: widget.top,
                      width: widget.width),
                  const SizedBox(height: 20),
                  const Text(
                      'Apparently, you didn\'t complete\n creating your last travel.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TravelsScreen(
                                userId: prefs.getString('uid') ?? '')),
                      );
                    },
                    child: Text('Continue to ${lastTravel.name}'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
