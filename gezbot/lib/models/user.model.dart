import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final DateTime birthDate;
  final DateTime createdAt;
  final String email;
  final String gender;
  final String photoUrl;
  final String userName;

  UserModel({
    required this.id,
    required this.birthDate,
    required this.createdAt,
    required this.email,
    required this.gender,
    required this.photoUrl,
    required this.userName,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      birthDate: (map['birthDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      email: map['email'],
      gender: map['gender'],
      photoUrl: map['photoUrl'],
      userName: map['userName'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'birthDate': birthDate as Timestamp,
      'createdAt': createdAt as Timestamp,
      'email': email,
      'gender': gender,
      'photoUrl': photoUrl,
      'userName': userName,
    };
  }

  factory UserModel.empty() {
    return UserModel(
      id: 'empty',
      birthDate: DateTime.now(),
      createdAt: DateTime.now(),
      email: 'empty',
      gender: 'empty',
      photoUrl: 'empty',
      userName: 'empty',
    );
  }
}
