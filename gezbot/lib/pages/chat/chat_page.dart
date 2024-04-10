import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gezbot/models/chat.model.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gezbot/shared/constants.dart';

class ChatScreen extends StatefulWidget {
  final String travelId;

  const ChatScreen({Key? key, required this.travelId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final DatabaseService dbService = DatabaseService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Future<Chat?> messagesFuture;
  late Future<Travel?> travelInfoFuture;
  // ignore: prefer_typing_uninitialized_variables
  late final prefs;
  @override
  void initState() {
    super.initState();
    _fetchPrefs();
    messagesFuture = dbService.getChat(widget.travelId);
    travelInfoFuture = dbService.getTravelOfUser(widget.travelId);

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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    String? userId = (await prefs).getString('uid');
    if (_messageController.text.trim().isNotEmpty && userId != null) {
      await dbService.sendMessage(
          widget.travelId, _messageController.text.trim(), userId);
      _messageController.clear();

      _updateMessagesAndScroll();
    }
  }

  void _updateMessagesAndScroll() async {
    setState(() {
      messagesFuture = dbService.getChat(widget.travelId);
    });

    messagesFuture.then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottomIfNeeded();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Travel?>(
          future: travelInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            if (snapshot.hasError) {
              return Text('Error 2: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Text('No Data');
            }
            Travel travelInfo = snapshot.data!;
            // Text('Chat Of ${travelInfo.name}');
            return SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/chatInfo',
                      arguments: travelInfo);
                },
                style: ElevatedButton.styleFrom(
                  surfaceTintColor: Colors.grey,
                ),
                child: Text(
                  'Chat Of ${travelInfo.name}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
              ),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _updateMessagesAndScroll,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/chat_background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<Chat?>(
                future: messagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('No Messages'));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error 3 : ${snapshot.error}'));
                  }

                  var messages = snapshot.data!.messages;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      //TODO #56 : check if the message is from the current user (async problem)
                      final isCurrentUser =
                          (messages[index].sender == prefs.getString('uid'));
                      return Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: isCurrentUser
                            ? messageBoxSenderMessage
                            : messageBoxRecieverMessage,
                        margin: isCurrentUser
                            ? const EdgeInsets.only(
                                right: 5.0, left: 50.0, top: 8.0)
                            : const EdgeInsets.only(
                                right: 50.0, left: 5.0, top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<UserModel>(
                              future: dbService.getUser(messages[index].sender),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    'Loading...',
                                    style: messageBoxName,
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Text(
                                    'Error 1: ${snapshot.error}',
                                    style: messageBoxName,
                                  );
                                }
                                if (!snapshot.hasData) {
                                  return Text(
                                    'No Data',
                                    style: messageBoxName,
                                  );
                                }
                                var senderName = snapshot.data!;
                                return Text(
                                  '${senderName.userName} :',
                                  style: messageBoxName,
                                );
                              },
                            ),
                            const SizedBox(height: 4.0),
                            Text(messages[index].message,
                                style: messageBoxMessage),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Text(
                    '* Ask question to AI, start message with @chatbot ',
                    textWidthBasis: TextWidthBasis.longestLine,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 4.0, left: 2.0, right: 2.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 50, // Adjust the height as desired
                      child: TextField(
                        onSubmitted: (_) => _sendMessage(),
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
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
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
