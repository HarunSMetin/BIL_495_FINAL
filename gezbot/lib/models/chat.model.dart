import 'package:gezbot/models/message.model.dart';

class Chat {
  final String id;
  final List<Message> messages;
  final List<String> members;

  Chat({
    required this.id,
    required this.messages,
    required this.members,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      messages: List<Message>.from(map['messages']),
      members: List<String>.from(map['members']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'messages': messages,
      'members': members,
    };
  }
}
