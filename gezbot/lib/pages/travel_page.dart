import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gezbot/services/database.dart';
import 'package:gezbot/pages/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelsScreen extends StatefulWidget {
  @override
  _TravelsScreenState createState() => _TravelsScreenState();
}

class Travel {
  final String name;
  final String description;
  final String startLocation;
  final String endLocation;
  final DateTime startDate;
  final DateTime endDate;
  final String id;
  // Add other fields as needed

  Travel({
    required this.id,
    required this.name,
    required this.description,
    required this.startLocation,
    required this.endLocation,
    required this.startDate,
    required this.endDate,

    // Initialize other fields in constructor
  });

  factory Travel.fromMap(Map<String, dynamic> map) {
    return Travel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      startLocation: map['startLocation'],
      endLocation: map['endLocation'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      // Initialize other fields using the map
    );
  }
}

class _TravelsScreenState extends State<TravelsScreen> {
  final DatabaseService dbService = DatabaseService();
  Future<List<Travel>>? travelsFuture;
  final ScrollController _scrollController = ScrollController();

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
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    if (userId != null) {
      var travelsData = await dbService.GetAllTravelsOfUser(userId);
      print(travelsData.entries.map((entry) => entry.value).toList());
      return travelsData.entries.map<Travel>((entry) {
        return Travel.fromMap({...entry.value, 'id': entry.key});
      }).toList();
    } else {
      return [];
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _refreshTravels();
    }
  }

  Future<void> _refreshTravels() async {
    setState(() {
      travelsFuture = _fetchTravels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Travels')),
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
                        builder: (context) => ChatScreen(travelId: travel.id),
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
