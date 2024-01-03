import 'package:flutter/material.dart';
import 'package:gezbot/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String travelId;
  ChatScreen({Key? key, required this.travelId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final DatabaseService dbService = DatabaseService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Future<Map<String, dynamic>> messagesFuture;

  @override
  void initState() {
    super.initState();
    messagesFuture = dbService.GetMessagesOfChat(widget.travelId);

    // Add WidgetsBinding observer
    WidgetsBinding.instance.addObserver(this);

    // Initial scroll to bottom
    _scrollToBottomOnMessagesLoad();
  }

  @override
  void dispose() {
    // Remove WidgetsBinding observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Handle changes in window metrics
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _scrollToBottomIfNeeded();
  }

  // Scroll to bottom on messages load
  void _scrollToBottomOnMessagesLoad() {
    messagesFuture.then((_) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToBottomIfNeeded());
    });
  }

  // Scroll to bottom if needed
  void _scrollToBottomIfNeeded() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Adjusted _sendMessage method
  Future<void> _sendMessage() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    if (_messageController.text.trim().isNotEmpty && userId != null) {
      await dbService.SendMessage(
          widget.travelId, _messageController.text.trim(), userId);
      _messageController.clear();

      // Update the messages and then scroll
      _updateMessagesAndScroll();
    }
  }

  // New method to update messages and then scroll
  void _updateMessagesAndScroll() {
    setState(() {
      messagesFuture = dbService.GetMessagesOfChat(widget.travelId);
    });

    // Scroll after a delay to ensure the list is updated
    messagesFuture.then((_) {
      Future.delayed(Duration(milliseconds: 300), () {
        _scrollToBottomIfNeeded();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData ||
                    snapshot.data![widget.travelId]['messages'] == null) {
                  return Center(child: Text('No Messages'));
                }

                var messages = snapshot.data![widget.travelId]['messages']
                    as List<Map<String, dynamic>>;
                return ListView.builder(
                  controller: _scrollController,
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
