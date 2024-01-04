import 'package:flutter/material.dart';
import 'package:gezbot/pages/chat_page.dart';
import 'package:gezbot/pages/travel_page.dart';

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
            Text("Description: ${travel.description}"),
            SizedBox(height: 8),
            Text("Start Location: ${travel.startLocation}"),
            SizedBox(height: 8),
            Text("End Location: ${travel.endLocation}"),
            SizedBox(height: 8),
            Text("Start Date: ${travel.startDate}"),
            SizedBox(height: 8),
            Text("End Date: ${travel.endDate}"),
            SizedBox(height: 20),
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
