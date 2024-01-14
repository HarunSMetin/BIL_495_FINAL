import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String message;
  final String sender;
  final Timestamp time;

  Message({
    required this.id,
    required this.message,
    required this.sender,
    required this.time,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      message: map['message'],
      sender: map['sender'],
      time: map['time'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'sender': sender,
      'time': time,
    };
  }
}
