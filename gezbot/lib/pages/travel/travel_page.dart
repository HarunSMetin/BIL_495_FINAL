import 'package:flutter/material.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gezbot/pages/travel/travel_info.dart';
import 'package:gezbot/pages/travel/pre_create_travel.dart';
import 'package:gezbot/models/travel.model.dart';

// ignore: must_be_immutable
class TravelsScreen extends StatefulWidget {
  String userId;
  String viewerId;
  TravelsScreen({super.key, required this.userId, this.viewerId = 'empty'});
  @override
  // ignore: library_private_types_in_public_api
  _TravelsScreenState createState() => _TravelsScreenState();
}

class _TravelsScreenState extends State<TravelsScreen> {
  final DatabaseService dbService = DatabaseService();
  Future<List<Travel>>? travelsFuture;
  late final SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    travelsFuture = _fetchTravels();
  }

  Future<List<Travel>> _fetchTravels() async {
    prefs = await SharedPreferences.getInstance();
    return dbService.getAllTravelsOfUserByShowStatus(
        widget.userId, widget.viewerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 174, 169, 248),
                Color.fromARGB(255, 146, 252, 243)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Travels',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTravel(context),
        tooltip: 'Add Travel',
        backgroundColor: Color.fromARGB(155, 168, 162, 248),
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/images/chat_background.jpg"), // Arka plan görselinizin yolu
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<Travel>>(
          future: travelsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No Travels Found'));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return _buildTravelsGrid(snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildTravelsGrid(List<Travel> travels) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      padding: const EdgeInsets.all(8.0),
      itemCount: travels.length,
      itemBuilder: (context, index) {
        final travel = travels[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TravelInformation(travel: travel),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade200, Colors.green.shade200],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  travel.name,
                  style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4.0),
                Text(
                  travel.description,
                  style: const TextStyle(fontSize: 14.0, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addOrEditTravel(BuildContext context) async {
    await dbService
        .getLastNotCompletedTravelOfUser(prefs.getString('uid') ?? '')
        .then((travel) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: PreTravelCreation(travel: travel ?? Travel.empty()),
          );
        },
      );
    });
  }
}
