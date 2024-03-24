import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gezbot/models/chat.model.dart';
import 'package:gezbot/models/message.model.dart';
import 'package:gezbot/models/question.model.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/services/google_cloud_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as developer;

class DatabaseService {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference userOptionsCollection =
      FirebaseFirestore.instance.collection('userOptions');
  final CollectionReference travelsCollection =
      FirebaseFirestore.instance.collection('travels');
  final CollectionReference travelOptionsCollection =
      FirebaseFirestore.instance.collection('travelOptions');
  final CollectionReference friendRequestsCollection =
      FirebaseFirestore.instance.collection('friendRequests');
  final GoogleCloudService _googleCloudService = GoogleCloudService();

  void printInlinedJson(Map<String, dynamic> jsonData, {String indent = ''}) {
    jsonData.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        developer.log('$indent$key: {');
        printInlinedJson(value, indent: '$indent  ');
        developer.log('$indent}');
      } else if (value is List) {
        developer.log('$indent[');
        for (var item in value) {
          if (item is Map<String, dynamic>) {
            printInlinedJson(item, indent: '$indent  ');
          } else {
            developer.log('$indent $item,');
          }
        }
        developer.log('$indent]');
      } else {
        developer.log('$indent$key: $value,');
      }
    });
  }

  Future<List<UserModel>> getAllUsers() async {
    QuerySnapshot querySnapshot = await userCollection.get();
    List<UserModel> users = List.empty(growable: true);
    await Future.forEach(querySnapshot.docs, (result) async {
      Map<String, dynamic> temp = result.data() as Map<String, dynamic>;
      temp['id'] = result.id;
      users.add(UserModel.fromMap(temp));
    });
    return users;
  }

  Future<UserModel> getUser(String userID) async {
    DocumentSnapshot doc = await userCollection.doc(userID).get();
    Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
    docData['id'] = doc.id;

    UserModel user = UserModel.fromMap(docData);

    return user;
  }

  Future<Map<String, dynamic>> getUserQuestions() async {
    QuerySnapshot querySnapshot = await userOptionsCollection.get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

/*
  Future AddQuestionToUser(
      String questionID, String Question, List<String> Answers) async {
    return await userOptionsCollection.doc(questionID).set({
      'question': Question,
      'answers': Answers,
    });
    /* 
      db.AddQuestionToUser("01_SpeedOfTravel", "What is your preferred travel pace?", ["Fast-paced, I like to see as much as possible.", "Moderate, I enjoy a good balance of activities and relaxation.", "Slow-paced, I prefer to take my time and soak in the experience."]);
      db.AddQuestionToUser("02_PreferredDestinations", "What kind of destinations do you usually prefer?", ["Urban cities with lots of activities and people.", "Natural and scenic places, away from the city.", "Cultural and historical sites."]);
      db.AddQuestionToUser("03_MainTravelGoal", "What is your main goal when you travel?", ["Adventure and excitement.", "Relaxation and rejuvenation.", "Cultural immersion and learning."]);
      db.AddQuestionToUser("04_TravelingPreferences", "How do you prefer to travel?", ["Solo, I enjoy my own company.", "With a partner or close friends.", "In groups, I love meeting new people."]);
      db.AddQuestionToUser("05_EveningPreferences", "How do you prefer to spend your evenings while traveling?", ["Experiencing the local nightlife and entertainment.", "Having a quiet dinner and a relaxing time.", "Planning the next day’s activities."]);
      db.AddQuestionToUser("06_ExcitingActivities", "Which of these activities excites you the most?", ["Exploring historical sites and museums.", "Adventure sports and outdoor activities.", "Relaxing on a beach or at a spa."]);
      db.AddQuestionToUser("07_BudgetConsideration", "How important is staying within budget while traveling?", ["Very important, I always stick to a budget.", "Moderately important, I'm flexible but mindful of expenses.", "Not important, I'm willing to spend for a great experience."]);
      db.AddQuestionToUser("08_AccommodationPreferences", "What type of accommodation do you usually prefer?", ["Budget-friendly hostels or guesthouses.", "Comfortable hotels with good amenities.", "Luxurious resorts or boutique hotels."]);
      db.AddQuestionToUser("09_ExoticFoodsAttitude", "How do you feel about trying new and exotic foods?", ["Love it, I'm always up for culinary adventures.", "I'm cautious but willing to try new things.", "Prefer sticking to familiar foods."]);
      db.AddQuestionToUser("10_TravelPlanningApproach", "When traveling, do you prefer to plan everything in advance or be spontaneous?", ["Plan everything, I like having a schedule.", "A mix of both planning and spontaneity.", "Be spontaneous, I enjoy the thrill of the unknown."]);
    */
  }

  Future AddQuestionToTravel(
      String questionID, String Question, List<String> Answers) async {
    return await travelOptionsCollection.doc(questionID).set({
      'question': Question,
      'answers': Answers,
    });
    /*
    db.AddQuestionToTravel("01_DepartureDate","What are your departure date?", ["[Calendar input for departure and return dates]"]);
    db.AddQuestionToTravel("02_ReturnDate","What are your return date?", ["[Calendar input for departure and return dates]"]);
    db.AddQuestionToTravel("03_DesiredDestination","What is your desired destination?", ["[Open-ended response, with suggestions based on popular destinations or a search functionality]"]);
    db.AddQuestionToTravel("04_TravelTransportation","How do you plan to travel to your destination?", [ "Airplane","Train","Bus","Car","Other [Open-ended response]" ]);
    db.AddQuestionToTravel("06_PurposeOfVisit","What is the primary purpose of your trip?", ["Leisure and relaxation","Adventure and exploration","Cultural experiences and sightseeing","Business or professional development"]);
    db.AddQuestionToTravel("05_EstimatedBudget","What is your estimated budget for this trip?", ["[Open-ended response or budget range options]"]);
    db.AddQuestionToTravel("07_AccommodationPreferences","Do you have any specific accommodation preferences?", ["Budget-friendly","Mid-range","Luxury","Unique or alternative lodging (e.g., Airbnb, hostels)"]);
    db.AddQuestionToTravel("08_ActivitiesPreferences","Are there any activities or experiences you particularly want to include?", ["Outdoor and adventure activities","Cultural and historical tours","Culinary experiences","Relaxation and wellness (e.g., spas, beaches)","Shopping and urban exploration","[Option for open-ended response]"]);
    db.AddQuestionToTravel("09_DietaryRestrictions","Do you have any dietary restrictions or preferences?", ["Vegetarian","Vegan","Gluten-free","No restrictions","Other [Open-ended response]"]);
    db.AddQuestionToTravel("10_TravelingWithOthers","Are you traveling alone or with others? If with others, how many people are in your group?", ["Alone","With another person","Small group (3-5 people)","Large group (more than 5 people)"]);
    db.AddQuestionToTravel("11_SpecialComment","Do you require any special services? (e.g., accessibility needs, child-friendly facilities)", ["[Open-ended response]"]);
    db.AddQuestionToTravel("12_LocalRecommendations","Would you like recommendations for local events or activities happening during your stay?", ["Yes","No"]);
    */
  }
*/

//USER_OPTIONS

  Future setUserOptions(String userID, String questionID, String answer) async {
    return userCollection.doc(userID).set({
      'userOptions': {questionID.substring(3): answer},
    }, SetOptions(merge: true));
  }

  Future getUserOptions(String userID) async {
    return (await userCollection.doc(userID).get())['userOptions'];
  }

//CHAT

  Future<Map<String, Chat>> getUserAllChats(String userID) async {
    //nested collection structure
    Map<String, Chat> chats = {};

    QuerySnapshot querySnapshot = await travelsCollection.get();
    await Future.forEach(querySnapshot.docs, (result) async {
      Map<String, dynamic> travelData = result.data() as Map<String, dynamic>;
      List<String> members = travelData['members'] as List<String>;
      if (members.contains(userID)) {
        QuerySnapshot nestedQuerySnapshot = await travelsCollection
            .doc(result.id)
            .collection('messages')
            .orderBy('time', descending: false)
            .get();

        List<Message> messages = [];
        for (var nestedResult in nestedQuerySnapshot.docs) {
          Map<String, dynamic> temp =
              nestedResult.data() as Map<String, dynamic>;
          temp['id'] = nestedResult.id;
          Message messageData = Message.fromMap(temp);
          messages.add(messageData);
        }

        chats[result.id] = Chat(
          id: result.id,
          messages: messages,
          members: members,
        );
      }
    });
    return chats;
  }

  Future<Chat> getChat(String travelID) async {
    QuerySnapshot querySnapshot = await travelsCollection
        .doc(travelID)
        .collection('messages')
        .orderBy('time', descending: false)
        .get();

    List<Message> messages = [];
    for (var result in querySnapshot.docs) {
      Map<String, dynamic> temp = result.data() as Map<String, dynamic>;
      temp['id'] = result.id;
      Message messageData = Message.fromMap(temp);
      messages.add(messageData);
    }
    Chat chat = Chat(
        id: travelID,
        messages: messages,
        members: List<String>.from(
            (await travelsCollection.doc(travelID).get())['members']));
    return chat;
  }

  Future sendMessage(String travelID, String message, String senderID) async {
    // travel Members check
    return await travelsCollection.doc(travelID).get().then((value) async {
      List<String> members = List<String>.from(value['members']);
      if (members.contains(senderID)) {
        await travelsCollection.doc(travelID).set({
          'lastUpdate': DateTime.now(),
        }, SetOptions(merge: true));
        // Chat Message Add
        travelsCollection.doc(travelID).collection('messages').add({
          'message': message,
          'sender': senderID,
          'time': DateTime.now(),
        }).then((value2) {
          travelsCollection
              .doc(travelID)
              .collection('messages')
              .doc(value2.id)
              .set({
            'id': value2.id,
          }, SetOptions(merge: true));
        });
      }
    });
  }

//TRAVELS

  Future<List<Travel>> _getAllTravelsOfUser(String userID) async {
    QuerySnapshot querySnapshot =
        await travelsCollection.where('members', arrayContains: userID).get();
    List<Travel> travels = [];
    await Future.forEach(querySnapshot.docs, (result) async {
      Map<String, dynamic> travelData = result.data() as Map<String, dynamic>;
      travelData['id'] = result.id;
      travels.add(Travel.fromMap(travelData));
    });
    return travels;
  }

  Future<List<Travel>> getAllPublicTravelsOfUser(String userID) async {
    QuerySnapshot querySnapshot = await travelsCollection
        .where('members', arrayContains: userID)
        .where('isPublic', isEqualTo: true)
        .get();
    List<Travel> travels = [];
    await Future.forEach(querySnapshot.docs, (result) async {
      Map<String, dynamic> travelData = result.data() as Map<String, dynamic>;
      travelData['id'] = result.id;
      travels.add(Travel.fromMap(travelData));
    });
    return travels;
  }

  Future<List<Travel>> getAllTravelsOfUserByShowStatus(String targetUserID,
      [String requesterUserID = 'empty']) async {
    if (targetUserID == requesterUserID ||
        await isFriend(targetUserID, requesterUserID) ||
        requesterUserID == 'empty') {
      return _getAllTravelsOfUser(targetUserID);
    } else {
      return getAllPublicTravelsOfUser(targetUserID);
    }
  }

  Future<int?> getNumberOfTravelsOfUser(String userID) async {
    AggregateQuerySnapshot count = await travelsCollection
        .where('members', arrayContains: userID)
        .count()
        .get();
    return count.count;
  }

  Future<Travel> getTravelOfUser(String travelID) async {
    DocumentSnapshot doc = await travelsCollection.doc(travelID).get();
    Map<String, dynamic> travelData = doc.data() as Map<String, dynamic>;
    travelData['id'] = doc.id;
    return Travel.fromMap(travelData);
  }

  Future<List<TravelQuestion>> getTravelQuestions(
      String userID, String travelID) async {
    QuerySnapshot querySnapshot = await travelOptionsCollection.get();
    List<TravelQuestion> questions = [];
    await Future.forEach(querySnapshot.docs, (result) async {
      Map<String, dynamic> temp = result.data() as Map<String, dynamic>;
      temp['questionId'] = result.id;
      questions.add(TravelQuestion.fromMap(temp));
    });
    await getTravelAnswersOfUser(userID, travelID).then((value) {
      for (var element in questions) {
        if (value[value.keys.toList().first].containsKey(element.questionId)) {
          dynamic userAnswer =
              value[value.keys.toList().first][element.questionId];
          /*if (_userAnswer != "") {
            element.userAnswer = _userAnswer;
          }*/
          if (userAnswer != null) {
            element.userAnswer = userAnswer;
          }
        }
      }
    });
    return questions;
  }

  Future<Map<String, dynamic>> getTravelAnswersOfUser(
      String userID, String travelID) async {
    //['01_DepartureDate','02_ReturnDate','03_DesiredDestination','04_TravelTransportation','06_PurposeOfVisit','05_EstimatedBudget','07_AccommodationPreferences','08_ActivitiesPreferences','09_DietaryRestrictions','10_TravelingWithOthers','11_SpecialComment','12_LocalRecommendations']

    Map<String, dynamic> jsonData = {};
    //get doc with id equals to travelID
    DocumentSnapshot doc = await travelsCollection.doc(travelID).get();
    Map<String, dynamic> travelData = doc.data() as Map<String, dynamic>;
    travelData['id'] = doc.id;
    jsonData[travelID] = travelData;

    return jsonData;
  }

  Future<Travel?> getLastNotCompletedTravelOfUser(String userId) async {
    QuerySnapshot querySnapshot = await travelsCollection
        .where('creatorId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .get();
    Map<String, dynamic> travelData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      travelData = result.data() as Map<String, dynamic>;
      travelData['id'] = result.id;
    });
    if (travelData.isEmpty) {
      return null;
    }
    return Travel.fromMap(travelData);
  }

  Future<Travel> completeTravel(String travelID) async {
    await travelsCollection.doc(travelID).set({
      'isCompleted': true,
    }, SetOptions(merge: true));
    return await getTravelOfUser(travelID);
  }
  //get lastCompletedQuestionOfTravel database contains: lastUpdatedQuestionId on travels

  Future createTravel(String userID, String travelName) async {
    var documentReference = await travelsCollection.add({
      'lastUpdatedQuestionId': '',
      'creatorId': userID,
      'name': travelName,
      'description': '',
      'isPublic': false,
      'isCompleted': false,
      'lastUpdate': DateTime.now(),
      'members': [userID],
      '00_DepartureLocation': '',
      '01_DesiredDestination': '',
      '02_DepartureDate': DateTime.now(),
      '03_ReturnDate': DateTime.now().add(const Duration(days: 1)),
      '04_TravelTransportation': '',
      '06_PurposeOfVisit': '',
      '05_EstimatedBudget': '',
      '07_AccommodationPreferences': '',
      '08_ActivitiesPreferences': '',
      '09_DietaryRestrictions': '',
      '10_TravelingWithOthers': '',
      '11_SpecialComment': '',
      '12_LocalRecommendations': '',
      'departureLocationGeoPoint': '',
      'desiredDestinationGeoPoint': '',
    });
    //create messages collection
    await travelsCollection
        .doc(documentReference.id)
        .collection('messages')
        .add({
      'message': 'Travel created',
      'sender': userID,
      'time': DateTime.now()
    });

    return documentReference.id;
  }

  Future updateTravel(
      String travelID, String questionId, dynamic answer) async {
    if (answer == null || answer == '') {
      return;
    }
    if (questionId == '00_DepartureLocation' ||
        questionId == '01_DesiredDestination') {
      //split on ,
      String latitude = answer.split(',')[0];
      String longtude = answer.split(',')[1];
      Map<String, String> address = await _googleCloudService
          .coordinatesToAddress(double.parse(latitude), double.parse(longtude),
              detailed: true);

      String allAddress = "";
      for (var item in address.values) {
        allAddress += '$item,';
      }
      if (questionId == '00_DepartureLocation') {
        return await travelsCollection.doc(travelID).set({
          questionId: allAddress,
          'lastUpdatedQuestionId': questionId,
          'lastUpdate': DateTime.now(),
          'departureLocationGeoPoint': answer,
        }, SetOptions(merge: true));
      } else {
        return await travelsCollection.doc(travelID).set({
          questionId: allAddress,
          'lastUpdatedQuestionId': questionId,
          'lastUpdate': DateTime.now(),
          'desiredDestinationGeoPoint': answer,
        }, SetOptions(merge: true));
      }
    }
    Map<String, dynamic> updateData = {};

    updateData[questionId] = answer;
    updateData['lastUpdatedQuestionId'] = questionId;
    updateData['lastUpdate'] = DateTime.now();

    return await travelsCollection
        .doc(travelID)
        .set(updateData, SetOptions(merge: true));
  }

  Future getLastQuestionOfTravel(String travelID) async {
    return (await travelsCollection
        .doc(travelID)
        .get())['lastUpdatedQuestionId'];
  }

  Future getAnswerOfQuestionOfTravel(String travelID, String questionID) async {
    return (await travelsCollection.doc(travelID).get())[questionID];
  }

  Future addFriendToTravel(
      String travelID, String userID, String friendID) async {
    if (userID == (await travelsCollection.doc(travelID).get())['creatorId'] &&
        await isFriend(userID, friendID)) {
      //add to travel
      await travelsCollection.doc(travelID).set({
        'members': FieldValue.arrayUnion([friendID])
      }, SetOptions(merge: true));
    }
  }

  Future removeFriendFromTravel(
      String travelID, String userID, String friendID) async {
    if (userID == (await travelsCollection.doc(travelID).get())['creatorId']) {
      //remove from travel
      await travelsCollection.doc(travelID).set({
        'members': FieldValue.arrayRemove([friendID])
      });
    }
  }

  Future deleteTravel(String travelID) async {
    await travelsCollection.doc(travelID).delete();
  }

//FRIENDS
  Future<List<UserModel>> getFollowingsOfUser(String userID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: userID)
        .where('status', isEqualTo: 'accepted')
        .get();

    List<UserModel> followings = [];
    for (var doc in querySnapshot.docs) {
      String followingId = (doc.data() as Map<String, dynamic>)['receiverId'];
      DocumentSnapshot userDoc = await userCollection.doc(followingId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        userData['id'] = followingId; // Add the followingId to the userData map
        followings.add(UserModel.fromMap(userData));
      }
    }
    return followings;
  }

  Future<List<UserModel>> getFollowersOfUser(String userID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('receiverId', isEqualTo: userID)
        .where('status', isEqualTo: 'accepted')
        .get();

    List<UserModel> followers = [];
    for (var doc in querySnapshot.docs) {
      String followerId = (doc.data() as Map<String, dynamic>)['senderId'];
      DocumentSnapshot userDoc = await userCollection.doc(followerId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        userData['id'] = followerId;
        followers.add(UserModel.fromMap(userData));
      }
    }
    return followers;
  }

//(GET) FRIEND REQUESTS (SENT)

  Future<List<UserModel>> getAcceptedFriendRequestsSentByUser(
      String userID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: userID)
        .where('status', isEqualTo: 'accepted')
        .get();

    List<UserModel> users = [];
    for (var doc in querySnapshot.docs) {
      String receiverId = (doc.data() as Map<String, dynamic>)['receiverId'];
      DocumentSnapshot userDoc = await userCollection.doc(receiverId).get();
      if (userDoc.exists) {
        users.add(UserModel.fromMap(userDoc.data() as Map<String, dynamic>));
      }
    }
    return users;
  }

  Future<List<UserModel>> getAcceptedFriendRequestsRecivedByUser(
      String userID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('receiverId', isEqualTo: userID)
        .where('status', isEqualTo: 'accepted')
        .get();

    List<UserModel> users = [];
    for (var doc in querySnapshot.docs) {
      String senderId = (doc.data() as Map<String, dynamic>)['senderId'];
      DocumentSnapshot userDoc = await userCollection.doc(senderId).get();
      if (userDoc.exists) {
        users.add(UserModel.fromMap(userDoc.data() as Map<String, dynamic>));
      }
    }
    return users;
  }

  Future<Map<String, dynamic>> getAllFriendRequestsSentByUser(
      String userID) async //Sent friend requests
  {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: userID)
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

  Future<int?> getNumberOfPendingFriendRequestsSentByUser(
      String userID) async //Sent friend requests
  {
    AggregateQuerySnapshot count = await friendRequestsCollection
        .where('senderId', isEqualTo: userID)
        .where('status', isEqualTo: 'pending')
        .count()
        .get();
    return count.count;
  }

  Future<Map<String, dynamic>> getPendingFriendRequestSentByUser(
      String userID) async // sent friend requests
  {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: userID)
        .where('status', isEqualTo: 'pending')
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

  Future<int?> getNumberOfAcceptedFriendRequestsSentByUser(
      String userID) async // sent friend requests
  {
    AggregateQuerySnapshot count = await friendRequestsCollection
        .where('senderId', isEqualTo: userID)
        .where('status', isEqualTo: 'accepted')
        .count()
        .get();
    return count.count;
  }

  Future<int?> getNumberOfDeclinedFriendRequestsSentByUser(
      String userID) async // sent friend requests
  {
    AggregateQuerySnapshot count = await friendRequestsCollection
        .where('senderId', isEqualTo: userID)
        .where('status', isEqualTo: 'declined')
        .count()
        .get();
    return count.count;
  }

  Future<Map<String, dynamic>> getDeclinedFriendRequestsSentByUser(
      String userID) async // sent friend requests
  {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: userID)
        .where('status', isEqualTo: 'declined')
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

//(GET) FRIEND REQUESTS (RECIVED)
  Future<Map<String, dynamic>> getAllFriendRequestsRecivedByUser(
      String userID) async // coming friend requests
  {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('receiverId', isEqualTo: userID)
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

  Future<int?> getNumberOfPendingFriendRequestsRecivedByUser(
      String userID) async // coming friend requests
  {
    AggregateQuerySnapshot count = await friendRequestsCollection
        .where('receiverId', isEqualTo: userID)
        .where('status', isEqualTo: 'pending')
        .count()
        .get();
    return count.count;
  }

  Future<Map<String, dynamic>> getPendingFriendRequestsRecivedByUser(
      String userID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('receiverId', isEqualTo: userID)
        .where('status', isEqualTo: 'pending')
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

  Future<int?> getNumberOfAcceptedFriendRequestsRecivedByUser(
      String userID) async {
    AggregateQuerySnapshot count = await friendRequestsCollection
        .where('receiverId', isEqualTo: userID)
        .where('status', isEqualTo: 'accepted')
        .count()
        .get();
    return count.count;
  }

  Future<int?> getNumberOfDeclinedFriendRequestsRecivedByUser(
      String userID) async // coming friend requests
  {
    AggregateQuerySnapshot count = await friendRequestsCollection
        .where('receiverId', isEqualTo: userID)
        .where('status', isEqualTo: 'declined')
        .count()
        .get();
    return count.count;
  }

  Future<Map<String, dynamic>> getDeclinedFriendRequestsRecivedByUser(
      String userID) async // coming friend requests
  {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('receiverId', isEqualTo: userID)
        .where('status', isEqualTo: 'declined')
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }
//(GET) SUM FRIEND REQ COUNTS

  Future<Map<String, dynamic>> getUserSummary(String userID) async {
    Map<String, dynamic> jsonData = {};
    jsonData['pendingSent'] =
        await getNumberOfPendingFriendRequestsSentByUser(userID);
    jsonData['acceptedSent'] =
        await getNumberOfAcceptedFriendRequestsSentByUser(userID);
    jsonData['declinedSent'] =
        await getNumberOfDeclinedFriendRequestsSentByUser(userID);
    jsonData['pendingReceived'] =
        await getNumberOfPendingFriendRequestsRecivedByUser(userID);
    jsonData['acceptedReceived'] =
        await getNumberOfAcceptedFriendRequestsRecivedByUser(userID);
    jsonData['declinedReceived'] =
        await getNumberOfDeclinedFriendRequestsRecivedByUser(userID);
    jsonData['travels'] = await getNumberOfTravelsOfUser(userID);
    return jsonData;
  }

//(POST) FRIEND REQUESTS
  Future<String> sendFriendRequest(String senderID, String receiverID) async {
    try {
      var querySnapshot = await friendRequestsCollection
          .where('senderId', isEqualTo: senderID)
          .where('receiverId', isEqualTo: receiverID)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var document = querySnapshot.docs.first;
        var documentId = document.id;
        await friendRequestsCollection.doc(documentId).update({
          'status': 'pending',
          'statusChangedAt': DateTime.now(),
        });
        return documentId;
      } else {
        var documentReference = await friendRequestsCollection.add({
          'senderId': senderID,
          'receiverId': receiverID,
          'status': 'pending',
          'sentAt': DateTime.now(),
          'statusChangedAt': DateTime.now(),
        });
        return documentReference.id;
      }
    } catch (e) {
      developer.log("Error in sending friend request: $e");
      return '';
    }
  }

  Future<bool> cancelFriendRequest(String senderId, String receiverId) async {
    try {
      var querySnapshot = await friendRequestsCollection
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentId = querySnapshot.docs.first.id;

        await friendRequestsCollection
            .doc(documentId)
            .update({'status': 'cancelled'});

        return true; // Successfully deleted or updated the request
      } else {
        return false; // No such request found
      }
    } catch (e) {
      developer.log("Error cancelling friend request: $e");
      return false; // An error occurred
    }
  }

  Future<bool> declineFriendRequest(String senderId, String receiverId) async {
    try {
      var querySnapshot = await friendRequestsCollection
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentId = querySnapshot.docs.first.id;

        await friendRequestsCollection
            .doc(documentId)
            .update({'status': 'declined'});

        return true; // Successfully deleted or updated the request
      } else {
        return false; // No such request found
      }
    } catch (e) {
      developer.log("Error declining friend request: $e");
      return false; // An error occurred
    }
  }

  Future acceptFriendRequest(String requestID) async {
    return await friendRequestsCollection.doc(requestID).set({
      'status': 'accepted',
      'statusChangedAt': DateTime.now(),
    }, SetOptions(merge: true));
  }

  /*Future DeclineFriendRequest(String requestID) async {
    return await friendRequestsCollection.doc(requestID).set({
      'status': 'declined',
      'statusChangedAt': DateTime.now(),
    }, SetOptions(merge: true));
  }*/

  Future removeFollower(String userID, String followerID) async {
    return await friendRequestsCollection
        .where('senderId', isEqualTo: followerID)
        .where('receiverId', isEqualTo: userID)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        await friendRequestsCollection.doc(value.docs[0].id).delete();
      }
    });
  }

  Future removeFollowing(String userID, String followingID) async {
    return await friendRequestsCollection
        .where('senderId', isEqualTo: userID)
        .where('receiverId', isEqualTo: followingID)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        await friendRequestsCollection.doc(value.docs[0].id).delete();
      }
    });
  }

  Future<bool> isFriend(String userID, String friendID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: userID)
        .where('receiverId', isEqualTo: friendID)
        .where('status', isEqualTo: 'accepted')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return true;
    }
    querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: friendID)
        .where('receiverId', isEqualTo: userID)
        .where('status', isEqualTo: 'accepted')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return true;
    }
    return false;
  }

  //SEARCH FUNCTIONS

  Future<List<UserModel>> _searchUsersByUserName(String query) async {
    QuerySnapshot querySnapshot = await userCollection
        .where('userName', isGreaterThanOrEqualTo: query.trim())
        .where('userName', isLessThanOrEqualTo: '${query.trim()}\uf8ff')
        .get();
    List<UserModel> users = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      userData['id'] = doc.id;
      users.add(UserModel.fromMap(userData));
    }
    return users;
  }

  Future<List<UserModel>> _searchUsersByEmail(String query) async {
    QuerySnapshot querySnapshot = await userCollection
        .where('email', isGreaterThanOrEqualTo: query.trim())
        .where('email', isLessThanOrEqualTo: '${query.trim()}\uf8ff')
        .get();

    List<UserModel> users = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      userData['id'] = doc.id;
      users.add(UserModel.fromMap(userData));
    }
    return users;
  }

  Future<List<UserModel>> searchByUserNameAndEmail(String query) async {
    List<UserModel> users = [];
    List<UserModel> email = await _searchUsersByEmail(query);

    users.addAll(await _searchUsersByUserName(query));
    for (var emailSearchUser in email) {
      bool isExist = false;
      for (var user in users) {
        if (user.id == emailSearchUser.id) {
          isExist = true;
        }
      }
      if (!isExist) {
        users.add(emailSearchUser);
      }
    }
    return users;
  }

  Future<Map<String, dynamic>> fetchRecommendedPlaces(String travelId) async {
    try {
      DocumentSnapshot doc = await travelsCollection.doc(travelId).get();
      if (!doc.exists) {
        throw Exception("Travel not found");
      }
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Assuming 'initialPosition' and 'pointsToMark' are stored as Strings
      String initialPositionStr = data['initialPosition'];
      List<String> pointsToMarkStrList = List.from(data['pointsToMark']);

      LatLng initialPosition = _parseLatLng(initialPositionStr);
      List<LatLng> pointsToMark = pointsToMarkStrList
          .map((pointStr) => _parseLatLng(pointStr))
          .toList();

      return {
        'initialPosition': initialPosition,
        'pointsToMark': pointsToMark,
      };
    } catch (e) {
      developer.log("Error fetching recommended places: $e");
      return {};
    }
  }

  LatLng _parseLatLng(String latLngStr) {
    List<String> parts = latLngStr.split(',');
    double latitude = double.parse(parts[0].trim());
    double longitude = double.parse(parts[1].trim());
    return LatLng(latitude, longitude);
  }

  Future<List<Travel>> searchTravelsByTravelName(String query,
      [String senderID = "empty"]) async {
    QuerySnapshot querySnapshot = await travelsCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '${query.trim()}\uf8ff')
        .where('isPublic', isEqualTo: true)
        .get();
    List<Travel> travels = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> travelData = doc.data() as Map<String, dynamic>;
      travelData['id'] = doc.id;
      travels.add(Travel.fromMap(travelData));
    }
    return travels;
  }

  Future<List<Travel>> _searchTravelsByUserEmail(String query,
      [String senderID = "empty"]) async {
    //find Travel creator id then match search id with creator id then get all travels of that user
    QuerySnapshot querySnapshot = await userCollection
        .where('email', isGreaterThanOrEqualTo: query.trim())
        .where('email', isLessThanOrEqualTo: '${query.trim()}\uf8ff')
        .limit(5)
        .get();
    List<Travel> travels = [];
    if (senderID == "empty") {
      for (var doc in querySnapshot.docs) {
        travels.addAll(await getAllPublicTravelsOfUser(doc.id));
      }
    } else {
      for (var doc in querySnapshot.docs) {
        travels.addAll(await getAllTravelsOfUserByShowStatus(doc.id, senderID));
      }
    }
    return travels;
  }

  Future<List<Travel>> _searchTravelsByUserName(String query,
      [String senderID = "empty"]) async {
    //find Travel creator id then match search id with creator id then get all travels of that user
    QuerySnapshot querySnapshot = await userCollection
        .where('userName', isGreaterThanOrEqualTo: query.trim())
        .where('userName', isLessThanOrEqualTo: '${query.trim()}\uf8ff')
        .limit(5)
        .get();
    List<Travel> travels = [];
    if (senderID == "empty") {
      for (var doc in querySnapshot.docs) {
        travels.addAll(await getAllPublicTravelsOfUser(doc.id));
      }
    } else {
      for (var doc in querySnapshot.docs) {
        travels.addAll(await getAllTravelsOfUserByShowStatus(doc.id, senderID));
      }
    }
    return travels;
  }

  Future<List<Travel>> searchTravelsByUserNameAndEmail(String query,
      [String senderID = 'empty']) async {
    List<Travel> travels = [];
    List<Travel> name = await _searchTravelsByUserName(query, senderID);
    travels.addAll(await _searchTravelsByUserEmail(query, senderID));
    for (var nameSearchTravel in name) {
      bool isExist = false;
      for (var travel in travels) {
        if (travel.id == nameSearchTravel.id) {
          isExist = true;
        }
      }
      if (!isExist) {
        travels.add(nameSearchTravel);
      }
    }
    return travels;
  }

  Future<List<Travel>> searchTravelsByDestination(String query) async {
    QuerySnapshot querySnapshot = await travelsCollection
        .where('03_DesiredDestination', isGreaterThanOrEqualTo: query.trim())
        .where('03_DesiredDestination',
            isLessThanOrEqualTo: '${query.trim()}\uf8ff')
        .where('isPublic', isEqualTo: true)
        .get();
    List<Travel> travels = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> travelData = doc.data() as Map<String, dynamic>;
      travelData['id'] = doc.id;
      travels.add(Travel.fromMap(travelData));
    }

    return travels;
  }
}
