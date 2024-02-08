import 'package:cloud_firestore/cloud_firestore.dart';

class Travel {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final bool isPublic;
  final bool isCompleted;
  final DateTime lastUpdate;
  final List<String> members;
  final String departureLocation;
  final DateTime departureDate;
  final DateTime returnDate;
  final String desiredDestination;
  final String travelTransportation;
  final String purposeOfVisit;
  final String estimatedBudget;
  final String accommodationPreferences;
  final String activitiesPreferences;
  final String dietaryRestrictions;
  final String travelingWithOthers;
  final String specialComment;
  final String localRecommendations;
  final String lastUpdatedQuestionId;

  Travel({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.isPublic,
    required this.isCompleted,
    required this.lastUpdate,
    required this.members,
    required this.departureLocation,
    required this.departureDate,
    required this.returnDate,
    required this.desiredDestination,
    required this.travelTransportation,
    required this.purposeOfVisit,
    required this.estimatedBudget,
    required this.accommodationPreferences,
    required this.activitiesPreferences,
    required this.dietaryRestrictions,
    required this.travelingWithOthers,
    required this.specialComment,
    required this.localRecommendations,
    required this.lastUpdatedQuestionId,
  });

  static void printErrorRed(e) {
    print('\x1B[31m$e\x1B[0m');
  }

  factory Travel.fromMap(Map<String, dynamic> map) {
    return Travel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      creatorId: map['creatorId'],
      isPublic: map['isPublic'],
      isCompleted: map['isCompleted'],
      lastUpdate: (map['lastUpdate'] as Timestamp).toDate(),
      members: List<String>.from(map['members']),
      departureLocation: map['00_DepartureLocation'],
      departureDate: (map['01_DepartureDate'] as Timestamp).toDate(),
      returnDate: (map['02_ReturnDate'] as Timestamp).toDate(),
      desiredDestination: map['03_DesiredDestination'],
      travelTransportation: map['04_TravelTransportation'],
      purposeOfVisit: map['06_PurposeOfVisit'],
      estimatedBudget: map['05_EstimatedBudget'],
      accommodationPreferences: map['07_AccommodationPreferences'],
      activitiesPreferences: map['08_ActivitiesPreferences'],
      dietaryRestrictions: map['09_DietaryRestrictions'],
      travelingWithOthers: map['10_TravelingWithOthers'],
      specialComment: map['11_SpecialComment'],
      localRecommendations: map['12_LocalRecommendations'],
      lastUpdatedQuestionId: map['lastUpdatedQuestionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'isPublic': isPublic,
      'isCompleted': isCompleted,
      'lastUpdate': lastUpdate,
      'members': members,
      'departureLocation': departureLocation,
      'departureDate': departureDate,
      'returnDate': returnDate,
      'desiredDestination': desiredDestination,
      'travelTransportation': travelTransportation,
      'purposeOfVisit': purposeOfVisit,
      'estimatedBudget': estimatedBudget,
      'accommodationPreferences': accommodationPreferences,
      'activitiesPreferences': activitiesPreferences,
      'dietaryRestrictions': dietaryRestrictions,
      'travelingWithOthers': travelingWithOthers,
      'specialComment': specialComment,
      'localRecommendations': localRecommendations,
      'lastUpdatedQuestionId': lastUpdatedQuestionId,
    };
  }

  factory Travel.empty() {
    return Travel(
      id: 'empty',
      name: 'empty',
      description: 'empty',
      creatorId: 'empty',
      isPublic: false,
      isCompleted: false,
      lastUpdate: DateTime.now(),
      members: [],
      departureLocation: 'empty',
      departureDate: DateTime.now(),
      returnDate: DateTime.now(),
      desiredDestination: 'empty',
      travelTransportation: 'empty',
      purposeOfVisit: 'empty',
      estimatedBudget: 'empty',
      accommodationPreferences: 'empty',
      activitiesPreferences: 'empty',
      dietaryRestrictions: 'empty',
      travelingWithOthers: 'empty',
      specialComment: 'empty',
      localRecommendations: 'empty',
      lastUpdatedQuestionId: 'empty',
    );
  }
  dynamic fieldFromQuestionId(String questionId) {
    switch (questionId) {
      case '00_DepartureLocation':
        return this.departureLocation;
      case '01_DepartureDate':
        return this.departureDate;
      case '02_ReturnDate':
        return this.returnDate;
      case '03_DesiredDestination':
        return this.desiredDestination;
      case '04_TravelTransportation':
        return this.travelTransportation;
      case '05_EstimatedBudget':
        return this.estimatedBudget;
      case '06_PurposeOfVisit':
        return this.purposeOfVisit;
      case '07_AccommodationPreferences':
        return this.accommodationPreferences;
      case '08_ActivitiesPreferences':
        return this.activitiesPreferences;
      case '09_DietaryRestrictions':
        return this.dietaryRestrictions;
      case '10_TravelingWithOthers':
        return this.travelingWithOthers;
      case '11_SpecialComment':
        return this.specialComment;
      case '12_LocalRecommendations':
        return this.localRecommendations;
      default:
        return null;
    }
  }

  String toString() {
    return 'Travel: {id: $id, name: $name, description: $description, creatorId: $creatorId, isPublic: $isPublic, isCompleted: $isCompleted, lastUpdate: $lastUpdate, members: $members, departureLocation: $departureLocation, departureDate: $departureDate, returnDate: $returnDate, desiredDestination: $desiredDestination, travelTransportation: $travelTransportation, purposeOfVisit: $purposeOfVisit, estimatedBudget: $estimatedBudget, accommodationPreferences: $accommodationPreferences, activitiesPreferences: $activitiesPreferences, dietaryRestrictions: $dietaryRestrictions, travelingWithOthers: $travelingWithOthers, specialComment: $specialComment, localRecommendations: $localRecommendations, lastUpdatedQuestionId: $lastUpdatedQuestionId}';
  }
}
