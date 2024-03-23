import 'package:flutter/material.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/shared/constants.dart';
import 'package:gezbot/components/UserInfoCard.dart';

// ignore: must_be_immutable
class ChatInfo extends StatelessWidget {
  final Travel travelInfo;
  final DatabaseService _databaseService = DatabaseService();
  ChatInfo({Key? key, required this.travelInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat Info',
          style: TextStyle(
            color: messageBoxMessageColor,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/chat_background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Travel Members',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkColor),
              ),
              const SizedBox(height: 16),
              for (var member in travelInfo.members) buildInfoRow(member),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(String userId) {
    return FutureBuilder<UserModel>(
      future: _databaseService.getUser(userId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserModel user = snapshot.data as UserModel;
          return UserInfoCard(user: user);
        } else {
          return Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
