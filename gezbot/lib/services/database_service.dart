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

  final List<String> userQuestions = [
    '01_SpeedOfTravel',
    '02_PreferredDestinations',
    '03_MainTravelGoal',
    '04_TravelingPreferences',
    '05_EveningPreferences',
    '06_ExcitingActivities',
    '07_BudgetConsideration',
    '08_AccommodationPreferences',
    '09_ExoticFoodsAttitude',
    '10_TravelPlanningApproach',
  ];

  final List<String> travelFields = [
    'lastUpdatedQuestionId',
    'creatorId',
    'name',
    'description',
    'isPublic',
    'isCompleted',
    'lastUpdate',
    'members',
    '01_DepartureDate',
    '02_ReturnDate',
    '03_DesiredDestination',
    '04_TravelTransportation',
    '06_PurposeOfVisit',
    '05_EstimatedBudget',
    '07_AccommodationPreferences',
    '08_ActivitiesPreferences',
    '09_DietaryRestrictions',
    '10_TravelingWithOthers',
    '11_SpecialComment',
    '12_LocalRecommendations'
  ];
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

  Future<Map<String, dynamic>> GetAllUsers() async {
    QuerySnapshot querySnapshot = await userCollection.get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

  Future<Map<String, dynamic>> GetUser(String UserID) async {
    DocumentSnapshot doc = await userCollection.doc(UserID).get();
    Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
    return userData;
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
        'id': result.id,
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
            .collection('messages')
            .orderBy('time', descending: false)
            .get();

        List<Map<String, dynamic>> messages = [];
        nestedQuerySnapshot.docs.forEach((nestedResult) {
          messages.add(nestedResult.data() as Map<String, dynamic>);
        });

        Map<String, dynamic> chatData = result.data() as Map<String, dynamic>;

        jsonData[result.id] = {
          'id': chatData['id'],
          'lastUpdate': chatData['lastUpdate'],
          'members': chatData['members'],
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
        .collection('messages')
        .orderBy('time', descending: false)
        .get();

    List<Map<String, dynamic>> messages = [];
    nestedQuerySnapshot.docs.forEach((nestedResult) {
      messages.add(nestedResult.data() as Map<String, dynamic>);
    });
    Map<String, dynamic> chatData = (await chatCollection.doc(TravelID).get())
        .data() as Map<String, dynamic>;
    jsonData[TravelID] = {
      'id': chatData['id'],
      'members': chatData['members'],
      'lastUpdate': chatData['lastUpdate'],
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
    DocumentReference doc =
        await chatCollection.doc(TravelID).collection('messages').add({
      'message': Message,
      'sender': SenderID,
      'time': DateTime.now(),
    });
    chatCollection.doc(TravelID).collection('messages').doc(doc.id).set({
      'id': doc.id,
    }, SetOptions(merge: true));
  }

//TRAVELS

  Future<Map<String, Map<String, dynamic>>> GetAllTravelsOfUser(
      String UserID) async {
    QuerySnapshot querySnapshot =
        await travelsCollection.where('creatorId', isEqualTo: UserID).get();
    Map<String, Map<String, dynamic>> jsonData = {};

    for (var doc in querySnapshot.docs) {
      jsonData[doc.id] = doc.data() as Map<String, dynamic>;
    }

    return jsonData;
  }

  Future<Map<String, dynamic>> GetTravelOfUser(
      String UserID, String TravelID) async {
    DocumentSnapshot doc = await travelsCollection.doc(TravelID).get();
    Map<String, dynamic> travelData = doc.data() as Map<String, dynamic>;
    return travelData;
  }

  Future<Map<String, dynamic>> GetTravelQuestions() async {
    QuerySnapshot querySnapshot = await travelOptionsCollection.get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

  Future<Map<String, dynamic>> GetTravelAnswersOfUser(String UserID) async {
    //['01_DepartureDate','02_ReturnDate','03_DesiredDestination','04_TravelTransportation','06_PurposeOfVisit','05_EstimatedBudget','07_AccommodationPreferences','08_ActivitiesPreferences','09_DietaryRestrictions','10_TravelingWithOthers','11_SpecialComment','12_LocalRecommendations']

    Map<String, dynamic> jsonData = {};
    QuerySnapshot querySnapshot =
        await travelsCollection.where('creatorId', isEqualTo: UserID).get();

    Map<String, dynamic> travelData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      travelData = result.data() as Map<String, dynamic>;
      jsonData[result.id] = {
        '01_DepartureDate': travelData['01_DepartureDate'],
        '02_ReturnDate': travelData['02_ReturnDate'],
        '03_DesiredDestination': travelData['03_DesiredDestination'],
        '04_TravelTransportation': travelData['04_TravelTransportation'],
        '06_PurposeOfVisit': travelData['06_PurposeOfVisit'],
        '05_EstimatedBudget': travelData['05_EstimatedBudget'],
        '07_AccommodationPreferences':
            travelData['07_AccommodationPreferences'],
        '08_ActivitiesPreferences': travelData['08_ActivitiesPreferences'],
        '09_DietaryRestrictions': travelData['09_DietaryRestrictions'],
        '10_TravelingWithOthers': travelData['10_TravelingWithOthers'],
        '11_SpecialComment': travelData['11_SpecialComment'],
        '12_LocalRecommendations': travelData['12_LocalRecommendations'],
      };
    });
    return jsonData;
  }

  Future<Map<String, dynamic>> GetLastNotCompletedTravelOfUser(
      String userId) async {
    QuerySnapshot querySnapshot = await travelsCollection
        .where('creatorId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .get();
    Map<String, dynamic> jsonData = {};
    await Future.forEach(querySnapshot.docs, (result) async {
      jsonData[result.id] = result.data() as Map<String, dynamic>;
    });
    return jsonData;
  }

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
    travelOptionsCollection.doc(documentReference.id).set({
      'id': documentReference.id,
    });
    //create chat for travel
    await chatCollection.doc(documentReference.id).set({
      'id': documentReference.id,
      'lastUpdate': DateTime.now(),
      'members': [UserID],
    });
    return documentReference.id;
  }

  Future UpdateTravel(
      String TravelID, String QuestionId, dynamic answer) async {
    Map<String, dynamic> updateData = {};

    updateData['QuestionId'] = answer;
    updateData['lastUpdatedQuestionId'] = QuestionId;
    updateData['lastUpdate'] = DateTime.now();

    return await travelsCollection
        .doc(TravelID)
        .set(updateData, SetOptions(merge: true));
  }

  Future AddFriendToTravel(
      String TravelID, String UserID, String FriendID) async {
    if (UserID == (await travelsCollection.doc(TravelID).get())['creatorId'] &&
        await IsFriend(UserID, FriendID)) {
      //add to travel
      await travelsCollection.doc(TravelID).set({
        'members': FieldValue.arrayUnion([FriendID])
      }, SetOptions(merge: true));
      //add to chat
      await chatCollection.doc(TravelID).set({
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
      //remove from chat
      await chatCollection.doc(TravelID).set({
        'members': FieldValue.arrayRemove([FriendID])
      });
    }
  }

  Future DeleteTravel(String TravelID) async {
    await travelsCollection.doc(TravelID).delete();
    await chatCollection.doc(TravelID).delete();
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

  Future<Map<String, dynamic>> GetAcceptedFriendRequestsSentByUser(
      String UserID) async // sent friend requests
  {
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

  Future<Map<String, dynamic>> GetPendingFriendRequestsRecivedByUser(
      String UserID) async // coming friend requests
  {
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

  Future<Map<String, dynamic>> GetAcceptedFriendRequestsRecivedByUser(
      String UserID) async // coming friend requests
  {
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

  Future<String> SendFriendRequest(String SenderID, String ReceiverID) async {
    var documentReference = await friendRequestsCollection.add({
      'senderId': SenderID,
      'receiverId': ReceiverID,
      'status': 'pending',
      'sentAt': DateTime.now(),
      'statusChangedAt': DateTime.now(),
    });
    return documentReference.id;
  }

  Future AcceptFriendRequest(String RequestID) async {
    return await friendRequestsCollection.doc(RequestID).set({
      'status': 'accepted',
      'statusChangedAt': DateTime.now(),
    });
  }

  Future DeclineFriendRequest(String RequestID) async {
    return await friendRequestsCollection.doc(RequestID).set({
      'status': 'declined',
      'statusChangedAt': DateTime.now(),
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
}
