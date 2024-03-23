import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final String departureLocationGeoPoint;
  final String desiredDestinationGeoPoint;

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
    required this.departureLocationGeoPoint,
    required this.desiredDestinationGeoPoint,
  });

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
      departureDate: (map['02_DepartureDate'] as Timestamp).toDate(),
      returnDate: (map['03_ReturnDate'] as Timestamp).toDate(),
      desiredDestination: map['01_DesiredDestination'],
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
      departureLocationGeoPoint: map['departureLocationGeoPoint'],
      desiredDestinationGeoPoint: map['desiredDestinationGeoPoint'],
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
      'departureLocationGeoPoint': departureLocationGeoPoint,
      'desiredDestinationGeoPoint': desiredDestinationGeoPoint,
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
      departureLocationGeoPoint: "empty",
      desiredDestinationGeoPoint: "empty",
    );
  }
  dynamic fieldFromQuestionId(String questionId) {
    switch (questionId) {
      case '00_DepartureLocation':
        return departureLocation;
      case '02_DepartureDate':
        return departureDate;
      case '03_ReturnDate':
        return returnDate;
      case '01_DesiredDestination':
        return desiredDestination;
      case '04_TravelTransportation':
        return travelTransportation;
      case '05_EstimatedBudget':
        return estimatedBudget;
      case '06_PurposeOfVisit':
        return purposeOfVisit;
      case '07_AccommodationPreferences':
        return accommodationPreferences;
      case '08_ActivitiesPreferences':
        return activitiesPreferences;
      case '09_DietaryRestrictions':
        return dietaryRestrictions;
      case '10_TravelingWithOthers':
        return travelingWithOthers;
      case '11_SpecialComment':
        return specialComment;
      case '12_LocalRecommendations':
        return localRecommendations;
      case 'departureLocationGeoPoint':
        return departureLocationGeoPoint;
      case 'desiredDestinationGeoPoint':
        return desiredDestinationGeoPoint;
      default:
        return null;
    }
  }

  @override
  String toString() {
    return 'Travel: {id: $id, name: $name, description: $description, creatorId: $creatorId, isPublic: $isPublic, isCompleted: $isCompleted, lastUpdate: $lastUpdate, members: $members, departureLocation: $departureLocation, departureDate: $departureDate, returnDate: $returnDate, desiredDestination: $desiredDestination, travelTransportation: $travelTransportation, purposeOfVisit: $purposeOfVisit, estimatedBudget: $estimatedBudget, accommodationPreferences: $accommodationPreferences, activitiesPreferences: $activitiesPreferences, dietaryRestrictions: $dietaryRestrictions, travelingWithOthers: $travelingWithOthers, specialComment: $specialComment, localRecommendations: $localRecommendations, lastUpdatedQuestionId: $lastUpdatedQuestionId} departureLocationGeoPoint: $departureLocationGeoPoint, desiredDestinationGeoPoint: $desiredDestinationGeoPoint}';
  }
}
