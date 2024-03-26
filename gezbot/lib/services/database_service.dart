import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gezbot/models/chat.model.dart';
import 'package:gezbot/models/message.model.dart';
import 'package:gezbot/models/question.model.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/services/backend.service.dart';
import 'package:gezbot/services/google_cloud_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as developer;
import 'package:gezbot/models/hotel.model.dart';

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
    Travel travel = await getTravelOfUser(travelID);
    BackendService(travel: travel).findHotels();
    BackendService(travel: travel).findPlaces();
    return travel;
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
        .where('01_DesiredDestination', isGreaterThanOrEqualTo: query.trim())
        .where('01_DesiredDestination',
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

  ////////////////////////////  HOTELS  ////////////////////////////

  Future<List<Hotel>> getHotels(String travelId) async {
    CollectionReference hotelsCollection =
        travelsCollection.doc(travelId).collection('hotels');

    List<Hotel> hotels = [];
    var Cats = ["relevance", "lowest_price", "highest_rating", "most_viewed"];

    for (var cat in Cats) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await hotelsCollection.doc(cat).collection('hotels').get();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> hotelData = new Map<String, dynamic>();
        try {
          hotelData = doc.data() as Map<String, dynamic>;
          hotelData['id'] = doc.id;
          hotels.add(Hotel.fromMap(hotelData));
        } catch (e) {
          print("Error on ID $cat - ${doc.id}: $e");
          continue;
        }
        hotelData['id'] = doc.id;
        hotels.add(Hotel.fromMap(hotelData));
      }
    }
    return hotels;
  }

  Future<Hotel> getFirstHotel(String travelId) async {
    List<Hotel> hotels = await getHotels(travelId);
    if (hotels.isEmpty) {
      return Hotel(
          id: "empty",
          name: '2The Green Park Hotel Bostancı',
          address:
              'İçerenköy, Ertaç Sk. No:16, 34752 Ataşehir/İstanbul, Türkiye',
          coordinates: [40.9666581, 29.1099791],
          price: 1300,
          amenities: [
            "Free breakfast",
            "Free Wi-Fi",
            "Free parking",
            "Pools",
            "Hot tub",
            "Air conditioning",
            "Fitness center",
            "Spa"
          ],
          icons: [
            "M4 19h16v2H4zM20 3H4v10c0 2.21 1.79 4 4 4h6c2.21 0 4-1.79 4-4v-3h2a2 2 0 0 0 2-2V5c0-1.11-.89-2-2-2zm-4 10c0 1.1-.9 2-2 2H8c-1.1 0-2-.9-2-2V5h10v8zm4-5h-2V5h2v3z",
            "M1 9l2 2c4.97-4.97 13.03-4.97 18 0l2-2C16.93 2.93 7.08 2.93 1 9zm8 8l3 3 3-3a4.237 4.237 0 0 0-6 0zm-4-4l2 2a7.074 7.074 0 0 1 10 0l2-2C15.14 9.14 8.87 9.14 5 13z",
            "M5.5 18h1c.28 0 .5-.22.5-.5v-1h10v1c0 .28.22.5.5.5h1c.28 0 .5-.22.5-.5v-6l-1.62-4.71c-.15-.46-.59-.79-1.1-.79H7.72c-.51 0-.94.33-1.1.79L5 11.5v6c0 .28.22.5.5.5zm1-6.25h11V15h-11v-3.25zM7.95 7.5h8.1l1 2.75H6.95l1-2.75zm8.05 6c0 .55-.45 1-1 1s-1-.45-1-1 .45-1 1-1 1 .45 1 1zm-6 0c0 .55-.45 1-1 1s-1-.45-1-1 .45-1 1-1 1 .45 1 1zM20 2H4c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 18H4V4h16v16z",
            "M10 8l-3.25 3.25c.31.12.56.27.77.39.37.23.59.36 1.15.36s.78-.13 1.15-.36c.46-.27 1.08-.64 2.19-.64s1.73.37 2.18.64c.37.22.6.36 1.15.36.55 0 .78-.13 1.15-.36.12-.07.26-.15.41-.23L10.48 5C8.93 3.45 7.5 2.99 5 3v2.5c1.82-.01 2.89.39 4 1.5l1 1zm12 8.5h-.02.02zm-16.65-1c.55 0 .78.14 1.15.36.45.27 1.07.64 2.18.64s1.73-.37 2.18-.64c.37-.23.59-.36 1.15-.36.55 0 .78.14 1.15.36.45.27 1.07.64 2.18.64s1.73-.37 2.18-.64c.37-.23.59-.36 1.15-.36.55 0 .78.14 1.15.36.45.27 1.06.63 2.16.64v-2c-.55 0-.78-.14-1.15-.36-.45-.27-1.07-.64-2.18-.64s-1.73.37-2.18.64c-.37.23-.6.36-1.15.36s-.78-.14-1.15-.36c-.45-.27-1.07-.64-2.18-.64s-1.73.37-2.18.64c-.37.23-.59.36-1.15.36-.55 0-.78-.14-1.15-.36-.45-.27-1.07-.64-2.18-.64s-1.73.37-2.18.64c-.37.23-.59.36-1.15.36v2c1.11 0 1.73-.37 2.2-.64.37-.23.6-.36 1.15-.36zM18.67 18c-1.11 0-1.73.37-2.18.64-.37.23-.6.36-1.15.36-.55 0-.78-.14-1.15-.36-.45-.27-1.07-.64-2.18-.64s-1.73.37-2.19.64c-.37.23-.59.36-1.15.36s-.78-.13-1.15-.36c-.45-.27-1.07-.64-2.18-.64s-1.73.37-2.19.64c-.37.23-.59.36-1.15.36v2c1.11 0 1.73-.37 2.19-.64.37-.23.6-.36 1.15-.36.55 0 .78.13 1.15.36.45.27 1.07.64 2.18.64s1.73-.37 2.19-.64c.37-.23.59-.36 1.15-.36.55 0 .78.14 1.15.36.45.27 1.07.64 2.18.64s1.72-.37 2.18-.64c.37-.23.59-.36 1.15-.36.55 0 .78.14 1.15.36.45.27 1.07.64 2.18.64v-2c-.56 0-.78-.13-1.15-.36-.45-.27-1.07-.64-2.18-.64z",
            "M11.15 12c-.31-.22-.59-.46-.82-.72l-1.4-1.55c-.19-.21-.43-.38-.69-.5-.29-.14-.62-.23-.96-.23h-.03C6.01 9 5 10.01 5 11.25V12H2v8c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2v-8H11.15zM7 20H5v-6h2v6zm4 0H9v-6h2v6zm4 0h-2v-6h2v6zm4 0h-2v-6h2v6zM17.42 7.21c.57.62.82 1.41.67 2.2l-.11.59h1.91l.06-.43c.21-1.36-.27-2.71-1.3-3.71l-.07-.07c-.57-.62-.82-1.41-.67-2.2L18 3h-1.89l-.06.43c-.2 1.36.27 2.71 1.3 3.72l.07.06zm-4 0c.57.62.82 1.41.67 2.2l-.11.59h1.91l.06-.43c.21-1.36-.27-2.71-1.3-3.71l-.07-.07c-.57-.62-.82-1.41-.67-2.2L14 3h-1.89l-.06.43c-.2 1.36.27 2.71 1.3 3.72l.07.06z",
            "M22 11h-4.17l3.24-3.24-1.41-1.42L15 11h-2V9l4.66-4.66-1.42-1.41L13 6.17V2h-2v4.17L7.76 2.93 6.34 4.34 11 9v2H9L4.34 6.34 2.93 7.76 6.17 11H2v2h4.17l-3.24 3.24 1.41 1.42L9 13h2v2l-4.66 4.66 1.42 1.41L11 17.83V22h2v-4.17l3.24 3.24 1.42-1.41L13 15v-2h2l4.66 4.66 1.41-1.42L17.83 13H22v-2z",
            "M20.57 14.86L22 13.43 20.57 12 17 15.57 8.43 7 12 3.43 10.57 2 9.14 3.43 7.71 2 5.57 4.14 4.14 2.71 2.71 4.14l1.43 1.43L2 7.71l1.43 1.43L2 10.57 3.43 12 7 8.43 15.57 17 12 20.57 13.43 22l1.43-1.43L16.29 22l2.14-2.14 1.43 1.43 1.43-1.43-1.43-1.43L22 16.29l-1.43-1.43z",
            "M11.48 14c.18.22.36.46.52.7.17-.24.34-.47.52-.7.7-.85 1.53-1.59 2.46-2.19C14.87 9.33 13.89 6.89 12 5c-1.89 1.89-2.87 4.33-2.98 6.81.92.6 1.75 1.34 2.46 2.19zM12 8.31c.43.79.72 1.65.87 2.55-.3.24-.59.5-.87.76-.28-.27-.57-.52-.87-.76.15-.89.44-1.76.87-2.55zM12 20a9 9 0 0 0 9-9 9 9 0 0 0-9 9zm2.44-2.44c.71-1.9 2.22-3.42 4.12-4.12a7.04 7.04 0 0 1-4.12 4.12zM3 11a9 9 0 0 0 9 9 9 9 0 0 0-9-9zm2.44 2.44c1.9.71 3.42 2.22 4.12 4.12a7.04 7.04 0 0 1-4.12-4.12z"
          ],
          rating: 3.5,
          reviewCount: 3395,
          link:
              'https://www.google.com/travel/search?q=Istanbul&ved=0CCQQyvcEahgKEwiIpOjlmo2FAxUAAAAAHQAAAAAQ6QE&ts=CAESCgoCCAMKAggDEAEaXwpBEj0KCS9tLzA5OTQ5bTIlMHgxNGNhYTcwNDAwNjgwODZiOjB4ZTFjY2ZlOThiYzAxYjBkMDoJxLBzdGFuYnVsGgASGhIUCgcI6A8QBRgSEgcI6A8QBhgBGA4yAggBKhUKEQoCIwkSAgQFOgNUUllaAhIOGgA&qs=CAEyJkNoZ0k0WmVEX2JXb2laYmxBUm9MTDJjdk1YUm5iR1F4TkhRUUFROA1IAA&ap=MAE');
    } else {
      return hotels.first;
    }
  }
}
