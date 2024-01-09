import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gezbot/pages/travel/create_travel_form.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/pages/chat/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gezbot/pages/travel/travel_info.dart';
import 'package:gezbot/pages/travel/pre_create_travel.dart';
import 'package:gezbot/models/travel.model.dart';

class TravelsScreen extends StatefulWidget {
  @override
  _TravelsScreenState createState() => _TravelsScreenState();
}

class _TravelsScreenState extends State<TravelsScreen> {
  final DatabaseService dbService = DatabaseService();
  Future<List<Travel>>? travelsFuture;
  final ScrollController _scrollController = ScrollController();
  bool isFetchingMore = false;
  late final prefs;

  @override
  void initState() {
    super.initState();
    travelsFuture = _fetchTravels();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Travel>> _fetchTravels() async {
    prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    if (userId != null) {
      var travelsData = await dbService.GetAllTravelsOfUser(userId);
      return travelsData.entries.map<Travel>((entry) {
        return Travel.fromMap({...entry.value, 'id': entry.key});
      }).toList();
    } else {
      return [];
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isFetchingMore) {
      _refreshTravels();
    }
  }

  Future<void> _refreshTravels() async {
    setState(() {
      isFetchingMore = true;
    });
    await Future.delayed(
        Duration(seconds: 2)); // TODO:Replace with actual fetch logic
    setState(() {
      travelsFuture = _fetchTravels();
      isFetchingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Travels')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print("here");
          await dbService.GetLastNotCompletedTravelOfUser(
                  prefs.getString('uid'))
              .then((value) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                if (value.values.isEmpty) {
                  return const Dialog(
                    child: PreTravelCreation(
                      travel: null,
                    ),
                  );
                } else {
                  return Dialog(
                    child: PreTravelCreation(
                      travel: Travel.fromMap(
                          {...value.values.first, 'id': value.keys.first}),
                    ),
                  );
                }
              },
            );
          });
          /*
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TravelQuestionnaireForm()),
          );
          */
        },
        child: Icon(Icons.add),
        tooltip: 'Add Travel',
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTravels,
        child: FutureBuilder<List<Travel>>(
          future: travelsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No Travels Found'));
            }

            List<Travel> travels = snapshot.data!;
            return ListView.builder(
              controller: _scrollController,
              itemCount: travels.length,
              itemBuilder: (context, index) {
                Travel travel = travels[index];
                return ListTile(
                  key: ValueKey(travel.id),
                  title: Text(travel.name),
                  subtitle: Text(travel.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravelInformation(travel: travel),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
