import 'package:flutter/material.dart';
import 'package:gezbot/services/scrapper_service.dart'; // Ensure this import points to your ScrapperService file

class FlightWidget extends StatefulWidget {
  @override
  _FlightWidgetState createState() => _FlightWidgetState();
}

class _FlightWidgetState extends State<FlightWidget> {
  late Future<List<dynamic>> flights;

  @override
  void initState() {
    super.initState();
    final scrapperService = ScrapperService();
    flights =
        scrapperService.getFlights('NYC', 'LAX', '2024-03-20', '2024-03-30');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Flights'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: flights,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var flight = snapshot.data![index];
                return ListTile(
                  title: Text("Flight ${flight['id']}"),
                  subtitle: Text(
                      "Departure: ${flight['Departure datetime']} - Arrival: ${flight['Arrival datetime']}"),
                );
              },
            );
          } else {
            return Center(child: Text("No flights found"));
          }
        },
      ),
    );
  }
}
