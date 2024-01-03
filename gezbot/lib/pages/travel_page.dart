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
}

class _TravelsScreenState extends State<TravelsScreen> {
  final DatabaseService dbService = DatabaseService();
  Future<List<Travel>>? travelsFuture;

  @override
  void initState() {
    super.initState();
    travelsFuture = _fetchTravels() as Future<List<Travel>>?;
  }

  Future<Object> _fetchTravels() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    if (userId != null) {
      return dbService.GetAllTravelsOfUser(userId);
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
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Travels Found'));
          }

          List<Travel> travels = snapshot.data!;
          return ListView.builder(
            itemCount: travels.length,
            itemBuilder: (context, index) {
              Travel travel = travels[index];
              return ListTile(
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
