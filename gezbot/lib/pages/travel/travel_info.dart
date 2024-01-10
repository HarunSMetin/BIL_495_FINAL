import 'package:flutter/material.dart';
import 'package:gezbot/pages/chat/chat_page.dart';
import 'package:gezbot/models/travel.model.dart';

class TravelInformation extends StatelessWidget {
  final Travel travel;

  TravelInformation({required this.travel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(travel.name)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Name: ${travel.name}"),
            SizedBox(height: 8),
            Text("Members: ${travel.members.join(', ')}"),
            SizedBox(height: 8),
            Text("Departure Date: ${travel.departureDate}"),
            SizedBox(height: 8),
            Text("Return Date: ${travel.returnDate}"),
            SizedBox(height: 8),
            Text("Desired Destination: ${travel.desiredDestination}"),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _openChatScreen(context, travel.id),
              child: Text('Chat about this travel'),
            ),
          ],
        ),
      ),
    );
  }

  void _openChatScreen(BuildContext context, String travelId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(travelId: travelId)),
    );
  }
}
