import 'package:flutter/material.dart';
import 'package:gezbot/services/database_service.dart';
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
      Map<String, Travel> travelsData =
          await dbService.GetAllTravelsOfUser(userId);
      return travelsData.values.toList();
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

    setState(() {
      travelsFuture = _fetchTravels();
      isFetchingMore = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Image Updated Successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Travels')),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await dbService.GetLastNotCompletedTravelOfUser(
                    prefs.getString('uid'))
                .then((value) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  if (value == null) {
                    return Dialog(
                      child: PreTravelCreation(
                        travel: Travel.empty(),
                      ),
                    );
                  } else {
                    return Dialog(
                      child: PreTravelCreation(
                        travel: value,
                      ),
                    );
                  }
                },
              );
            });
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
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No Travels Found'));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              List<Travel> travels = snapshot.data!;
              return Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: ListView.builder(
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
                                builder: (context) =>
                                    TravelInformation(travel: travel),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ));
  }
}
