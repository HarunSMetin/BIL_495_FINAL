import 'package:flutter/material.dart';
import 'package:gezbot/pages/chat/chat_page.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:ticket_widget/ticket_widget.dart';

// class TravelInformation extends StatelessWidget {
//   final Travel travel;

//   TravelInformation({required this.travel});

//   @override
//   Widget build(BuildContext context) {2
//     return Scaffold(
//       appBar: AppBar(title: Text(travel.name)),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text("Name: ${travel.name}"),
//             SizedBox(height: 8),
//             Text("Members: ${travel.members.join(', ')}"),
//             SizedBox(height: 8),
//             Text("Departure Date: ${travel.departureDate}"),
//             SizedBox(height: 8),
//             Text("Return Date: ${travel.returnDate}"),
//             SizedBox(height: 8),
//             Text("Desired Destination: ${travel.desiredDestination}"),
//             SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: () => _openChatScreen(context, travel.id),
//               child: Text('Chat about this travel'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _openChatScreen(BuildContext context, String travelId) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => ChatScreen(travelId: travelId)),
//     );
//   }
// }

class TravelInfo extends StatelessWidget {
  final Travel travel;

  TravelInfo({required this.travel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Travel Info'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          InfoCard(
            title: 'Members',
            content: 'List of members goes here...',
          ),
          SizedBox(height: 16.0),
          InfoCard(
            title: 'Date',
            content: 'Travel date information goes here...',
          ),
          SizedBox(height: 16.0),
          InfoCard(
            title: 'Special Comments',
            content: 'Any special comments go here...',
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatefulWidget {
  final String title;
  final String content;

  InfoCard({required this.title, required this.content});

  @override
  _InfoCardState createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFD2FFF4),
      child: Column(
        children: [
          ListTile(
            leading: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
            title: Text(widget.title),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.content),
            ),
        ],
      ),
    );
  }
}
