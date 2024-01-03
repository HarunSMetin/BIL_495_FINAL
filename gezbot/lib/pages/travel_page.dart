import 'package:flutter/material.dart';
import 'package:gezbot/services/database.dart';
import 'package:gezbot/pages/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelsScreen extends StatefulWidget {
  @override
  _TravelsScreenState createState() => _TravelsScreenState();
}

class Travel {
  final String id;
  final String title;
  final String description;

  Travel({required this.id, required this.title, required this.description});

  // Factory constructor to create a Travel instance from a map
  factory Travel.fromMap(Map<String, dynamic> map) {
    return Travel(
      id: map['id'], // Replace 'id' with the actual key in the map
      title: map['title'], // Replace 'title' with the actual key in the map
      description: map[
          'description'], // Replace 'description' with the actual key in the map
    );
  }
}

class _TravelsScreenState extends State<TravelsScreen> {
  final DatabaseService dbService = DatabaseService();
  Future<List<Travel>>? travelsFuture;

  @override
  void initState() {
    super.initState();
    travelsFuture = _fetchTravels();
  }

  Future<List<Travel>> _fetchTravels() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    if (userId != null) {
      var travelsData = await dbService.GetAllTravelsOfUser(userId);
      List<Travel> travels = travelsData.entries.map<Travel>((entry) {
        return Travel.fromMap({...entry.value, 'id': entry.key});
      }).toList();
      return travels;
    } else {
      return []; // Return an empty list or handle the case where userId is null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Travels')),
      body: FutureBuilder<List<Travel>>(
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
            itemCount: travels.length,
            itemBuilder: (context, index) {
              Travel travel = travels[index];
              return ListTile(
                key: ValueKey(travel.id), // Using unique keys for each ListTile
                title: Text(travel.title),
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
    );
  }
}
