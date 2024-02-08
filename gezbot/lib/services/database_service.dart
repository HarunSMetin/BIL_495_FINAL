import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gezbot/models/chat.model.dart';
import 'package:gezbot/models/message.model.dart';
import 'package:gezbot/models/question.model.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  void printError(e) {
    print('\x1B[31m$e\x1B[0m');
  }

  void printWarning(e) {
    print('\x1B[33m$e\x1B[0m');
  }

  void printOkey(e) {
    print('\x1B[32m$e\x1B[0m');
  }

  void printInlinedJson(Map<String, dynamic> jsonData, {String indent = ''}) {
    jsonData.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        print('$indent$key: {');
        printInlinedJson(value, indent: '$indent  ');
        print('$indent}');
      } else if (value is List) {
        print('$indent$key: [');
        for (var item in value) {
          if (item is Map<String, dynamic>) {
            printInlinedJson(item, indent: '$indent  ');
          } else {
            print('$indent  $item,');
          }
        }
        print('$indent]');
      } else {
        print('$indent$key: $value,');
      }
    });
  }

  Future<List<UserModel>> GetAllUsers() async {
    QuerySnapshot querySnapshot = await userCollection.get();
    List<UserModel> Users = List.empty(growable: true);
    await Future.forEach(querySnapshot.docs, (result) async {
      Map<String, dynamic> temp = result.data() as Map<String, dynamic>;
      temp['id'] = result.id;
      Users.add(UserModel.fromMap(temp));
    });
    return Users;
  }

  Future<UserModel> GetUser(String UserID) async {
    DocumentSnapshot doc = await userCollection.doc(UserID).get();
    Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
    docData['id'] = doc.id;

    UserModel user = UserModel.fromMap(docData);

    return user;
  }

  Future<Map<String, dynamic>> GetUserQuestions() async {
    QuerySnapshot querySnapshot = await userOptionsCollection.get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

/*
  Future AddQuestionToUser(
      String QuestionID, String Question, List<String> Answers) async {
    return await userOptionsCollection.doc(QuestionID).set({
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
      String QuestionID, String Question, List<String> Answers) async {
    return await travelOptionsCollection.doc(QuestionID).set({
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

  Future SetUserOptions(String UserID, String QuestionID, String Answer) async {
    return userCollection.doc(UserID).set({
      'userOptions': {QuestionID.substring(3): Answer},
    }, SetOptions(merge: true));
  }

  Future GetUserOptions(String UserID) async {
    return (await userCollection.doc(UserID).get())['userOptions'];
  }

//CHAT

  Future<Map<String, Chat>> GetUserAllChats(String UserID) async {
    //nested collection structure
    Map<String, Chat> chats = {};

    QuerySnapshot querySnapshot = await travelsCollection.get();
    await Future.forEach(querySnapshot.docs, (result) async {
      Map<String, dynamic> travelData = result.data() as Map<String, dynamic>;
      List<String> members = travelData['members'] as List<String>;
      if (members.contains(UserID)) {
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

  Future<Chat> GetChat(String TravelID) async {
    QuerySnapshot querySnapshot = await travelsCollection
        .doc(TravelID)
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
        id: TravelID,
        messages: messages,
        members: List<String>.from(
            (await travelsCollection.doc(TravelID).get())['members']));
    return chat;
  }

  Future SendMessage(String TravelID, String Message, String SenderID) async {
    // travel Members check
    return await travelsCollection.doc(TravelID).get().then((value) async {
      List<String> members = List<String>.from(value['members']);
      if (members.contains(SenderID)) {
        await travelsCollection.doc(TravelID).set({
          'lastUpdate': DateTime.now(),
        }, SetOptions(merge: true));
        // Chat Message Add
        travelsCollection.doc(TravelID).collection('messages').add({
          'message': Message,
          'sender': SenderID,
          'time': DateTime.now(),
        }).then((value2) {
          travelsCollection
              .doc(TravelID)
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

  Future<List<Travel>> _getAllTravelsOfUser(String UserID) async {
    QuerySnapshot querySnapshot =
        await travelsCollection.where('members', arrayContains: UserID).get();
    List<Travel> travels = [];
    await Future.forEach(querySnapshot.docs, (result) async {
      Map<String, dynamic> travelData = result.data() as Map<String, dynamic>;
      travelData['id'] = result.id;
      travels.add(Travel.fromMap(travelData));
    });
    return travels;
  }

  Future<List<Travel>> GetAllPublicTravelsOfUser(String UserID) async {
    QuerySnapshot querySnapshot = await travelsCollection
        .where('members', arrayContains: UserID)
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

  Future<List<Travel>> GetAllTravelsOfUserByShowStatus(String TargetUserID,
      [String RequesterUserID = 'empty']) async {
    if (TargetUserID == RequesterUserID ||
        await IsFriend(TargetUserID, RequesterUserID) ||
        RequesterUserID == 'empty') {
      return _getAllTravelsOfUser(TargetUserID);
    } else {
      return GetAllPublicTravelsOfUser(TargetUserID);
    }
  }

  Future<int?> GetNumberOfTravelsOfUser(String UserID) async {
    AggregateQuerySnapshot count = await travelsCollection
        .where('members', arrayContains: UserID)
        .count()
        .get();
    return count.count;
  }

  Future<Travel> GetTravelOfUser(String TravelID) async {
    DocumentSnapshot doc = await travelsCollection.doc(TravelID).get();
    Map<String, dynamic> travelData = doc.data() as Map<String, dynamic>;
    travelData['id'] = doc.id;
    return Travel.fromMap(travelData);
  }

  Future<List<TravelQuestion>> GetTravelQuestions(
      String UserID, String TravelID) async {
    QuerySnapshot querySnapshot = await travelOptionsCollection.get();
    List<TravelQuestion> questions = [];
    await Future.forEach(querySnapshot.docs, (result) async {
      Map<String, dynamic> temp = result.data() as Map<String, dynamic>;
      temp['questionId'] = result.id;
      questions.add(TravelQuestion.fromMap(temp));
    });
    await GetTravelAnswersOfUser(UserID, TravelID).then((value) {
      questions.forEach((element) {
        if (value[value.keys.toList().first].containsKey(element.questionId)) {
          dynamic _userAnswer =
              value[value.keys.toList().first][element.questionId];
          /*if (_userAnswer != "") {
            element.userAnswer = _userAnswer;
          }*/
          if (_userAnswer != null) {
            element.userAnswer = _userAnswer;
          }
        }
      });
    });
    return questions;
  }

  Future<Map<String, dynamic>> GetTravelAnswersOfUser(
      String UserID, String TravelID) async {
    //['01_DepartureDate','02_ReturnDate','03_DesiredDestination','04_TravelTransportation','06_PurposeOfVisit','05_EstimatedBudget','07_AccommodationPreferences','08_ActivitiesPreferences','09_DietaryRestrictions','10_TravelingWithOthers','11_SpecialComment','12_LocalRecommendations']

    Map<String, dynamic> jsonData = {};
    //get doc with id equals to TravelID
    DocumentSnapshot doc = await travelsCollection.doc(TravelID).get();
    Map<String, dynamic> travelData = doc.data() as Map<String, dynamic>;
    travelData['id'] = doc.id;
    jsonData[TravelID] = travelData;

    printOkey(jsonData);
    return jsonData;
  }

  Future<Travel?> GetLastNotCompletedTravelOfUser(String userId) async {
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

  Future<Travel> CompleteTravel(String TravelID) async {
    await travelsCollection.doc(TravelID).set({
      'isCompleted': true,
    }, SetOptions(merge: true));
    return await GetTravelOfUser(TravelID);
  }
  //Get lastCompletedQuestionOfTravel database contaions: lastUpdatedQuestionId on travels

  Future CreateTravel(String UserID, String travelName) async {
    var documentReference = await travelsCollection.add({
      'lastUpdatedQuestionId': '',
      'creatorId': UserID,
      'name': travelName,
      'description': '',
      'isPublic': false,
      'isCompleted': false,
      'lastUpdate': DateTime.now(),
      'members': [UserID],
      '00_DepartureLocation': '',
      '01_DepartureDate': DateTime(1010, 10, 10),
      '02_ReturnDate': DateTime(1010, 10, 10),
      '03_DesiredDestination': '',
      '04_TravelTransportation': '',
      '06_PurposeOfVisit': '',
      '05_EstimatedBudget': '',
      '07_AccommodationPreferences': '',
      '08_ActivitiesPreferences': '',
      '09_DietaryRestrictions': '',
      '10_TravelingWithOthers': '',
      '11_SpecialComment': '',
      '12_LocalRecommendations': '',
    });
    //create messages collection
    await travelsCollection
        .doc(documentReference.id)
        .collection('messages')
        .add({
      'message': 'Travel created',
      'sender': UserID,
      'time': DateTime.now()
    });

    return documentReference.id;
  }

  Future UpdateTravel(
      String TravelID, String QuestionId, dynamic answer) async {
    if (answer == null) {
      return;
    }
    Map<String, dynamic> updateData = {};

    updateData[QuestionId] = answer;
    updateData['lastUpdatedQuestionId'] = QuestionId;
    updateData['lastUpdate'] = DateTime.now();

    return await travelsCollection
        .doc(TravelID)
        .set(updateData, SetOptions(merge: true));
  }

  Future getLastQuestionOfTravel(String TravelID) async {
    return (await travelsCollection
        .doc(TravelID)
        .get())['lastUpdatedQuestionId'];
  }

  Future getAnswerOfQuestionOfTravel(String TravelID, String QuestionID) async {
    return (await travelsCollection.doc(TravelID).get())[QuestionID];
  }

  Future AddFriendToTravel(
      String TravelID, String UserID, String FriendID) async {
    if (UserID == (await travelsCollection.doc(TravelID).get())['creatorId'] &&
        await IsFriend(UserID, FriendID)) {
      //add to travel
      await travelsCollection.doc(TravelID).set({
        'members': FieldValue.arrayUnion([FriendID])
      }, SetOptions(merge: true));
    }
  }

  Future RemoveFriendFromTravel(
      String TravelID, String UserID, String FriendID) async {
    if (UserID == (await travelsCollection.doc(TravelID).get())['creatorId']) {
      //remove from travel
      await travelsCollection.doc(TravelID).set({
        'members': FieldValue.arrayRemove([FriendID])
      });
    }
  }

  Future DeleteTravel(String TravelID) async {
    await travelsCollection.doc(TravelID).delete();
  }

//FRIENDS
  Future<List<UserModel>> GetFollowingsOfUser(String UserID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: UserID)
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

  Future<List<UserModel>> GetFollowersOfUser(String UserID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('receiverId', isEqualTo: UserID)
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

  Future<List<UserModel>> GetAcceptedFriendRequestsSentByUser(
      String UserID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: UserID)
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

  Future<List<UserModel>> GetAcceptedFriendRequestsRecivedByUser(
      String UserID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('receiverId', isEqualTo: UserID)
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

  Future<Map<String, dynamic>> GetAllFriendRequestsSentByUser(
      String UserID) async //Sent friend requests
  {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: UserID)
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

  Future<int?> GetNumberOfPendingFriendRequestsSentByUser(
      String UserID) async //Sent friend requests
  {
    AggregateQuerySnapshot count = await friendRequestsCollection
        .where('senderId', isEqualTo: UserID)
        .where('status', isEqualTo: 'pending')
        .count()
        .get();
    return count.count;
  }

  Future<Map<String, dynamic>> GetPendingFriendRequestSentByUser(
      String UserID) async // sent friend requests
  {
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

  Future<int?> GetNumberOfAcceptedFriendRequestsSentByUser(
      String UserID) async // sent friend requests
  {
    AggregateQuerySnapshot count = await friendRequestsCollection
        .where('senderId', isEqualTo: UserID)
        .where('status', isEqualTo: 'accepted')
        .count()
        .get();
    return count.count;
  }

  Future<int?> GetNumberOfDeclinedFriendRequestsSentByUser(
      String UserID) async // sent friend requests
  {
    AggregateQuerySnapshot count = await friendRequestsCollection
        .where('senderId', isEqualTo: UserID)
        .where('status', isEqualTo: 'declined')
        .count()
        .get();
    return count.count;
  }

  Future<Map<String, dynamic>> GetDeclinedFriendRequestsSentByUser(
      String UserID) async // sent friend requests
  {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: UserID)
        .where('status', isEqualTo: 'declined')
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

//(GET) FRIEND REQUESTS (RECIVED)
  Future<Map<String, dynamic>> GetAllFriendRequestsRecivedByUser(
      String UserID) async // coming friend requests
  {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('receiverId', isEqualTo: UserID)
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

  Future<int?> GetNumberOfPendingFriendRequestsRecivedByUser(
      String UserID) async // coming friend requests
  {
    AggregateQuerySnapshot count = await friendRequestsCollection
        .where('receiverId', isEqualTo: UserID)
        .where('status', isEqualTo: 'pending')
        .count()
        .get();
    return count.count;
  }

  Future<Map<String, dynamic>> GetPendingFriendRequestsRecivedByUser(
      String UserID) async {
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

  Future<int?> GetNumberOfAcceptedFriendRequestsRecivedByUser(
      String UserID) async {
    AggregateQuerySnapshot count = await friendRequestsCollection
        .where('receiverId', isEqualTo: UserID)
        .where('status', isEqualTo: 'accepted')
        .count()
        .get();
    return count.count;
  }

  Future<int?> GetNumberOfDeclinedFriendRequestsRecivedByUser(
      String UserID) async // coming friend requests
  {
    AggregateQuerySnapshot count = await friendRequestsCollection
        .where('receiverId', isEqualTo: UserID)
        .where('status', isEqualTo: 'declined')
        .count()
        .get();
    return count.count;
  }

  Future<Map<String, dynamic>> GetDeclinedFriendRequestsRecivedByUser(
      String UserID) async // coming friend requests
  {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('receiverId', isEqualTo: UserID)
        .where('status', isEqualTo: 'declined')
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }
//(GET) SUM FRIEND REQ COUNTS

  Future<Map<String, dynamic>> GetUserSummary(String UserID) async {
    Map<String, dynamic> jsonData = {};
    jsonData['pendingSent'] =
        await GetNumberOfPendingFriendRequestsSentByUser(UserID);
    jsonData['acceptedSent'] =
        await GetNumberOfAcceptedFriendRequestsSentByUser(UserID);
    jsonData['declinedSent'] =
        await GetNumberOfDeclinedFriendRequestsSentByUser(UserID);
    jsonData['pendingReceived'] =
        await GetNumberOfPendingFriendRequestsRecivedByUser(UserID);
    jsonData['acceptedReceived'] =
        await GetNumberOfAcceptedFriendRequestsRecivedByUser(UserID);
    jsonData['declinedReceived'] =
        await GetNumberOfDeclinedFriendRequestsRecivedByUser(UserID);
    jsonData['travels'] = await GetNumberOfTravelsOfUser(UserID);
    return jsonData;
  }

//(POST) FRIEND REQUESTS
  Future<String> SendFriendRequest(String SenderID, String ReceiverID) async {
    try {
      var querySnapshot = await friendRequestsCollection
          .where('senderId', isEqualTo: SenderID)
          .where('receiverId', isEqualTo: ReceiverID)
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
          'senderId': SenderID,
          'receiverId': ReceiverID,
          'status': 'pending',
          'sentAt': DateTime.now(),
          'statusChangedAt': DateTime.now(),
        });
        return documentReference.id;
      }
    } catch (e) {
      print("Error in sending friend request: $e");
      return '';
    }
  }

  Future<bool> CancelFriendRequest(String senderId, String receiverId) async {
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
      print("Error cancelling friend request: $e");
      return false; // An error occurred
    }
  }

  Future<bool> DeclineFriendRequest(String senderId, String receiverId) async {
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
      print("Error declining friend request: $e");
      return false; // An error occurred
    }
  }

  Future AcceptFriendRequest(String RequestID) async {
    return await friendRequestsCollection.doc(RequestID).set({
      'status': 'accepted',
      'statusChangedAt': DateTime.now(),
    }, SetOptions(merge: true));
  }

  /*Future DeclineFriendRequest(String RequestID) async {
    return await friendRequestsCollection.doc(RequestID).set({
      'status': 'declined',
      'statusChangedAt': DateTime.now(),
    }, SetOptions(merge: true));
  }*/

  Future removeFollower(String UserID, String FollowerID) async {
    return await friendRequestsCollection
        .where('senderId', isEqualTo: FollowerID)
        .where('receiverId', isEqualTo: UserID)
        .get()
        .then((value) async {
      if (value.docs.length > 0) {
        await friendRequestsCollection.doc(value.docs[0].id).delete();
      }
    });
  }

  Future removeFollowing(String UserID, String FollowingID) async {
    return await friendRequestsCollection
        .where('senderId', isEqualTo: UserID)
        .where('receiverId', isEqualTo: FollowingID)
        .get()
        .then((value) async {
      if (value.docs.length > 0) {
        await friendRequestsCollection.doc(value.docs[0].id).delete();
      }
    });
  }

  Future<bool> IsFriend(String UserID, String FriendID) async {
    QuerySnapshot querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: UserID)
        .where('receiverId', isEqualTo: FriendID)
        .where('status', isEqualTo: 'accepted')
        .get();
    if (querySnapshot.docs.length > 0) {
      return true;
    }
    querySnapshot = await friendRequestsCollection
        .where('senderId', isEqualTo: FriendID)
        .where('receiverId', isEqualTo: UserID)
        .where('status', isEqualTo: 'accepted')
        .get();
    if (querySnapshot.docs.length > 0) {
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

  Future<List<UserModel>> SearchByUserNameAndEmail(String query) async {
    List<UserModel> users = [];
    List<UserModel> email = await _searchUsersByEmail(query);

    users.addAll(await _searchUsersByUserName(query));
    for (var emailsearchuser in email) {
      bool isExist = false;
      for (var user in users) {
        if (user.id == emailsearchuser.id) {
          isExist = true;
        }
      }
      if (!isExist) {
        users.add(emailsearchuser);
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
      print("Error fetching recommended places: $e");
      return {};
    }
  }

  LatLng _parseLatLng(String latLngStr) {
    List<String> parts = latLngStr.split(',');
    double latitude = double.parse(parts[0].trim());
    double longitude = double.parse(parts[1].trim());
    return LatLng(latitude, longitude);
  }

  Future<List<Travel>> SearchTravelsByTravelName(String query,
      [String SenderID = "empty"]) async {
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
      [String SenderID = "empty"]) async {
    //find Travel creator id then match search id with creator id then get all travels of that user
    QuerySnapshot querySnapshot = await userCollection
        .where('email', isGreaterThanOrEqualTo: query.trim())
        .where('email', isLessThanOrEqualTo: '${query.trim()}\uf8ff')
        .limit(5)
        .get();
    List<Travel> travels = [];
    if (SenderID == "empty") {
      for (var doc in querySnapshot.docs) {
        travels.addAll(await GetAllPublicTravelsOfUser(doc.id));
      }
    } else {
      for (var doc in querySnapshot.docs) {
        travels.addAll(await GetAllTravelsOfUserByShowStatus(doc.id, SenderID));
      }
    }
    return travels;
  }

  Future<List<Travel>> _searchTravelsByUserName(String query,
      [String SenderID = "empty"]) async {
    //find Travel creator id then match search id with creator id then get all travels of that user
    QuerySnapshot querySnapshot = await userCollection
        .where('userName', isGreaterThanOrEqualTo: query.trim())
        .where('userName', isLessThanOrEqualTo: '${query.trim()}\uf8ff')
        .limit(5)
        .get();
    List<Travel> travels = [];
    if (SenderID == "empty") {
      for (var doc in querySnapshot.docs) {
        travels.addAll(await GetAllPublicTravelsOfUser(doc.id));
      }
    } else {
      for (var doc in querySnapshot.docs) {
        travels.addAll(await GetAllTravelsOfUserByShowStatus(doc.id, SenderID));
      }
    }
    return travels;
  }

  Future<List<Travel>> SearchTravelsByUserNameAndEmail(String query,
      [String SenderID = 'empty']) async {
    List<Travel> travels = [];
    List<Travel> name = await _searchTravelsByUserName(query, SenderID);
    travels.addAll(await _searchTravelsByUserEmail(query, SenderID));
    for (var namesearchtravel in name) {
      bool isExist = false;
      for (var travel in travels) {
        if (travel.id == namesearchtravel.id) {
          isExist = true;
        }
      }
      if (!isExist) {
        travels.add(namesearchtravel);
      }
    }
    return travels;
  }

  Future<List<Travel>> SearchTravelsByDestination(String query) async {
    print(query);
    QuerySnapshot querySnapshot = await travelsCollection
        .where('03_DesiredDestination', isGreaterThanOrEqualTo: query.trim())
        .where('03_DesiredDestination',
            isLessThanOrEqualTo: '${query.trim()}\uf8ff')
        .where('isPublic', isEqualTo: true)
        .get();
    print(querySnapshot.docs.length);
    List<Travel> travels = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> travelData = doc.data() as Map<String, dynamic>;
      travelData['id'] = doc.id;
      travels.add(Travel.fromMap(travelData));
    }

    return travels;
  }
}
