import 'package:flutter/material.dart';
import 'package:gezbot/services/database.dart';

class ChatScreen extends StatefulWidget {
  final String travelId; // Assuming this is the chat room ID
  ChatScreen({Key? key, required this.travelId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseService dbService = DatabaseService();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await dbService.SendMessage(
          widget.travelId,
          _messageController.text.trim(),
          "SenderID"); // Replace SenderID with actual sender ID
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: dbService.GetMessagesOfChat(widget.travelId)
                  .asStream(), // Convert Future to Stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return Center(child: Text('No Messages'));
                }

                var messages = snapshot.data!['messages'];
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index]['message']),
                      subtitle: Text('Sent by: ${messages[index]['sender']}'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
