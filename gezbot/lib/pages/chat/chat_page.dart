import 'package:flutter/material.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gezbot/shared/constants.dart';

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
  late Future<Map<String, dynamic>?> messagesFuture;
  late Future<Map<String, dynamic>?> travelInfoFuture;
  late final prefs;
  @override
  void initState() {
    super.initState();
    _fetchPrefs();
    messagesFuture = dbService.GetMessagesOfChat(widget.travelId);
    travelInfoFuture = dbService.GetTravelOfUser(widget.travelId);

    WidgetsBinding.instance.addObserver(this);

    _scrollToBottomOnMessagesLoad();
  }

  void _fetchPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _scrollToBottomIfNeeded();
  }

  void _scrollToBottomOnMessagesLoad() {
    messagesFuture.then((_) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToBottomIfNeeded());
    });
  }

  void _scrollToBottomIfNeeded() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    String? userId = (await prefs).getString('uid');
    if (_messageController.text.trim().isNotEmpty && userId != null) {
      await dbService.SendMessage(
          widget.travelId, _messageController.text.trim(), userId);
      _messageController.clear();

      _updateMessagesAndScroll();
    }
  }

  void _updateMessagesAndScroll() async {
    setState(() {
      messagesFuture = dbService.GetMessagesOfChat(widget.travelId);
    });

    messagesFuture.then((_) {
      Future.delayed(Duration(milliseconds: 300), () {
        _scrollToBottomIfNeeded();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>?>(
          future: travelInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            }
            if (snapshot.hasError) {
              return Text('Error : ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return Text('No Data');
            }
            var travelInfo = snapshot.data!;
            return Text('Chat Of ${travelInfo['name']}');
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _updateMessagesAndScroll,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/chat_background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<Map<String, dynamic>?>(
                future: messagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data![widget.travelId]['messages'] == null) {
                    return Center(child: Text('No Messages'));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error : ${snapshot.error}'));
                  }

                  var messages = snapshot.data![widget.travelId]['messages']
                      as List<Map<String, dynamic>>;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      //TODO : check if the message is from the current user (async problem)
                      final isCurrentUser =
                          (messages[index]['sender'] == prefs.getString('uid'));
                      return Container(
                        padding: EdgeInsets.all(12.0),
                        decoration: isCurrentUser
                            ? MessageBoxSenderMessage
                            : MessageBoxRecieverMessage,
                        margin: isCurrentUser
                            ? EdgeInsets.only(right: 5.0, left: 50.0, top: 8.0)
                            : EdgeInsets.only(right: 50.0, left: 5.0, top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Map<String, dynamic>>(
                              future:
                                  dbService.GetUser(messages[index]['sender']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    'Loading...',
                                    style: MessageBoxName,
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Text(
                                    'Error: ${snapshot.error}',
                                    style: MessageBoxName,
                                  );
                                }
                                if (!snapshot.hasData) {
                                  return Text(
                                    'No Data',
                                    style: MessageBoxName,
                                  );
                                }
                                var senderName = snapshot.data!;
                                return Text(
                                  senderName['userName'] + ' :',
                                  style: MessageBoxName,
                                );
                              },
                            ),
                            SizedBox(height: 4.0),
                            Text(messages[index]['message'],
                                style: MessageBoxMessage),
                          ],
                        ),
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
                      decoration: InputDecoration(
                        labelText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
