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
  Future SetUserOptions(String UserID, String QuestionID, String AnswerID) {
    //TODO: Düzenleme yapılacak
    return userOptionsCollection.doc(UserID).set({
      QuestionID: AnswerID,
    }, SetOptions(merge: true));
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
        .collection('messages')
        .orderBy('time', descending: false)
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
    });
  }

//TRAVELS

  Future<Map<String, Map<String, dynamic>>> GetAllTravelsOfUser(
      String UserID) async {
    QuerySnapshot querySnapshot =
        await travelsCollection.where('creatorId', isEqualTo: UserID).get();
    Map<String, Map<String, dynamic>> jsonData = {};

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> travelData = doc.data() as Map<String, dynamic>;
      travelData['id'] = doc.id;
      jsonData[doc.id] = travelData;
    }

    return jsonData;
  }

  Future CreateTravel(String UserID) async {
    var documentReference = await travelsCollection.add({
      'creatorId': UserID,
      'createdAt': DateTime.now(),
      'lastUpdate': DateTime.now(),
      'members': [UserID],
      'name': 'New Travel',
      'description': 'New Travel Description',
      'startDate': DateTime.now(),
      'endDate': DateTime.now(),
      'startLocation': 'New Travel Start Location',
      'endLocation': 'New Travel End Location',
      'isPublic': false,
      'transportation': 'New Travel Transportation',
      'purpose': 'New Travel Purpose',
      'budget': 'New Travel Budget',
      'accommodation': 'New Travel Accommodation',
      'activities': 'New Travel Activities',
      'dietaryRestrictions': 'New Travel Dietary Restrictions',
      'travelingWithOthers': 'New Travel Traveling With Others',
      'specialComment': 'New Travel Special Comment',
      'localRecommendations': 'New Travel Local Recommendations',
    });
    //create chat for travel
    await chatCollection.doc(documentReference.id).set({
      'lastUpdate': DateTime.now(),
      'members': [UserID],
    });
    return documentReference.id;
  }

  Future UpdateTravel(
      String TravelID, String QuestionId, dynamic answer) async {
    Map<String, dynamic> updateData = {};
    switch (QuestionId) {
      case '01_DepartureDate':
        updateData['startDate'] = answer;
        break;
      case '02_ReturnDate':
        updateData['endDate'] = answer;
        break;
      case '03_DesiredDestination':
        updateData['endLocation'] = answer;
        break;
      case 'startLocation':
        updateData['startLocation'] = answer;
        break;
      case '04_TravelTransportation':
        updateData['transportation'] = answer;
        break;
      case '06_PurposeOfVisit':
        updateData['purpose'] = answer;
        break;
      case '05_EstimatedBudget':
        updateData['budget'] = answer;
        break;
      case '07_AccommodationPreferences':
        updateData['accommodation'] = answer;
        break;
      case '08_ActivitiesPreferences':
        updateData['activities'] = answer;
        break;
      case '09_DietaryRestrictions':
        updateData['dietaryRestrictions'] = answer;
        break;
      case '10_TravelingWithOthers':
        updateData['travelingWithOthers'] = answer;
        break;
      case '11_SpecialComment':
        updateData['specialComment'] = answer;
        break;
      case '12_LocalRecommendations':
        updateData['localRecommendations'] = answer;
        break;
      case 'name':
        updateData['name'] = answer;
        break;
      case 'description':
        updateData['description'] = answer;
        break;
      case 'isPublic':
        updateData['isPublic'] = answer;
        break;

      default:
        break;
    }

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
}
