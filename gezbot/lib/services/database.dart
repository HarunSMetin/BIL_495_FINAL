import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chats');
  final CollectionReference userOptionsCollection =
      FirebaseFirestore.instance.collection('userOptions');
  final CollectionReference travelsCollection =
      FirebaseFirestore.instance.collection('travels');
  final CollectionReference travelOptionsCollection =
      FirebaseFirestore.instance.collection('travelOptions');

  final CollectionReference friendRequestsCollection =
      FirebaseFirestore.instance.collection('friendRequests');

//CHAT
  Future<Map<String, dynamic>> GetAllChats() async {
    //nested collection structure
    Map<String, dynamic> jsonData = {};

    QuerySnapshot querySnapshot = await chatCollection.get();
    await Future.forEach(querySnapshot.docs, (result) async {
      QuerySnapshot nestedQuerySnapshot = await chatCollection
          .doc(result.id)
          .collection('messages') // Replace with your nested collection name
          .get();

      List<Map<String, dynamic>> messages = [];
      nestedQuerySnapshot.docs.forEach((nestedResult) {
        messages.add(nestedResult.data() as Map<String, dynamic>);
      });

      jsonData[result.id] = {
        'lastUpdate': (result.data() as Map<String, dynamic>)['lastUpdate'],
        'members': (result.data() as Map<String, dynamic>)['members'],
        'messages': messages,
      };
    });

    return jsonData;
  }

  Future<Map<String, dynamic>> GetUserAllChats(String UserID) async {
    //nested collection structure
    Map<String, dynamic> jsonData = {};

    QuerySnapshot querySnapshot = await chatCollection.get();
    await Future.forEach(querySnapshot.docs, (result) async {
      List members = (result.data() as Map<String, dynamic>)['members'];
      if (members.contains(UserID)) {
        QuerySnapshot nestedQuerySnapshot = await chatCollection
            .doc(result.id)
            .collection('messages') // Replace with your nested collection name
            .get();

        List<Map<String, dynamic>> messages = [];
        nestedQuerySnapshot.docs.forEach((nestedResult) {
          messages.add(nestedResult.data() as Map<String, dynamic>);
        });

        jsonData[result.id] = {
          'lastUpdate': (result.data() as Map<String, dynamic>)['lastUpdate'],
          'members': (result.data() as Map<String, dynamic>)['members'],
          'messages': messages,
        };
      }
    });
    return jsonData;
  }

  Future<Map<String, dynamic>> GetMessagesOfChat(String TravelID) async {
    Map<String, dynamic> jsonData = {};
    QuerySnapshot nestedQuerySnapshot = await chatCollection
        .doc(TravelID)
        .collection('messages') // Replace with your nested collection name
        .get();

    List<Map<String, dynamic>> messages = [];
    nestedQuerySnapshot.docs.forEach((nestedResult) {
      messages.add(nestedResult.data() as Map<String, dynamic>);
    });

    jsonData[TravelID] = {
      'members': (await chatCollection.doc(TravelID).get()).data()
          as Map<String, dynamic>,
      'messages': messages,
    };
    return jsonData;
  }

  Future SendMessage(String TravelID, String Message, String SenderID) async {
    await chatCollection.doc(TravelID).set({
      'lastUpdate': DateTime.now(),
      'members': [],
    }, SetOptions(merge: true));

    // Chat Members Update
    var documentReference = chatCollection.doc(TravelID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(documentReference);

      if (!snapshot.exists) {
        throw Exception("Document does not exist!");
      }

      List<dynamic> currentArray = snapshot.get('members') ?? [];

      if (!currentArray.contains(SenderID)) {
        transaction.set(
            documentReference,
            {
              'members': FieldValue.arrayUnion([SenderID])
            },
            SetOptions(merge: true));
      }
    });
    // Chat Message Add
    return await chatCollection.doc(TravelID).collection('messages').add({
      'message': Message,
      'sender': SenderID,
      'time': DateTime.now(),
    }) as bool;
  }

//TRAVELS

  Future<Map<String, dynamic>> GetAllTravelsOfUser(String UserID) async {
    QuerySnapshot querySnapshot =
        await travelsCollection.where('creatorId', isEqualTo: UserID).get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

//FRIENDS
  Future<Map<String, dynamic>> GetFollowingsOfUser(String UserID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: UserID)
        .where('status', isEqualTo: 'accepted')
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

  Future<Map<String, dynamic>> GetFollowersOfUser(String UserID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('receiverId', isEqualTo: UserID)
        .where('status', isEqualTo: 'accepted')
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }
//FRIEND REQUESTS

  Future<Map<String, dynamic>> GetFriendRequestsOfUser(String UserID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('receiverId', isEqualTo: UserID)
        .where('status', isEqualTo: 'pending')
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

  Future<Map<String, dynamic>> GetSentFriendRequestsOfUser(
      String UserID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: UserID)
        .where('status', isEqualTo: 'pending')
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

  Future<bool> SendFriendRequest(String SenderID, String ReceiverID) async {
    return await friendRequestsCollection.add({
      'senderId': SenderID,
      'receiverId': ReceiverID,
      'status': 'pending',
      'sentAt': DateTime.now(),
      'statusChangedAt': DateTime.now(),
    }) as bool;
  }
}
