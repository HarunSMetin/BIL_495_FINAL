import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId:
          "1027985224810-jeioofe75dtanigd4r1vtgv4v4glemis.apps.googleusercontent.com");

  //EMAIL

  final String defaultProfilePicUrl =
      "data:image/png;base64,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";
  //"https://w7.pngwing.com/pngs/178/595/png-transparent-user-profile-computer-icons-login-user-avatars-thumbnail.png";

  Future<UserCredential> registerUser({
    required String email,
    required String password,
    required String username,
    required Function(String) showErrorDialog,
    required BuildContext context,
  }) async {
    if (username.isEmpty) {
      showErrorDialog('Username cannot be empty.');
      return Future.error('Username is empty');
    }

    // Check if username already exists in Firestore
    var users = await _firestore
        .collection('users')
        .where('userName', isEqualTo: username)
        .get();
    if (users.docs.isNotEmpty) {
      showErrorDialog(
          'Username already exists. Please choose a different one.');
      return Future.error('Username already exists');
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(username);
        await user.updatePhotoURL(defaultProfilePicUrl);

        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'userName': username,
          'createdAt': DateTime.now().toIso8601String(),
          'photoUrl': defaultProfilePicUrl, // Adding the photo URL to Firestore
        });
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', username);
      await prefs.setString('uid', user?.uid ?? '');
      await prefs.setString('photoUrl', defaultProfilePicUrl);
      await prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacementNamed(context, '/home');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showErrorDialog('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showErrorDialog('An account already exists for that email.');
      } else {
        showErrorDialog(e.message ?? 'An error occurred. Please try again.');
      }
      rethrow;
    } catch (e) {
      showErrorDialog('An error occurred. Please try again.');
      rethrow;
    }
  }

  Future<void> updateUsername({
    required String userId,
    required String username,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'userName': username,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', username);
    } catch (e) {
      throw Exception('Failed to update username: $e');
    }
  }

  Future<void> updateUserProfilePhoto({
    required String userId,
    required String imagePath,
    required Function(String) showErrorDialog,
  }) async {
    try {
      File imageFile = File(imagePath);
      String fileName = 'user_images/$userId/profile.jpg';

      TaskSnapshot taskSnapshot =
          await _storage.ref(fileName).putFile(imageFile);
      String photoUrl = await taskSnapshot.ref.getDownloadURL();

      await _firestore.collection('users').doc(userId).update({
        'photoUrl': photoUrl,
      });

      // Optionally, update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('photoUrl', photoUrl);
    } on FirebaseException catch (e) {
      showErrorDialog('Failed to upload image: ${e.message}');
    } catch (e) {
      showErrorDialog('An error occurred. Please try again.');
    }
  }

  Future<void> updateUserBirthDate({
    required String userId,
    required DateTime birthDate,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'birthDate': birthDate.toIso8601String(),
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('birthDate', birthDate.toIso8601String());
  }

  Future<void> updateGender(
      {required String userId, required String gender}) async {
    await _firestore.collection('users').doc(userId).update({
      'gender': gender,
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gender', gender);
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
    required Function(String) showErrorDialog,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await fetchAndStoreUserDetails(user.uid);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      showErrorDialog(e.message ?? 'An error occurred. Please try again.');
    }
  }

  //GOOGLE

  Future<void> signUpWithGoogle({
    required Function(String) showErrorDialog,
    required BuildContext context,
  }) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    Future<void> updateUserGender({
      required String userId,
      required Gender gender,
    }) async {
      await _firestore.collection('users').doc(userId).update({
        'gender': gender.toString().split('.').last,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gender', gender.toString().split('.').last);
    }

    UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    User? user = userCredential.user;
    final prefs = await SharedPreferences.getInstance();

    if (user != null) {
      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
      if (!docSnapshot.exists) {
        var uuid = const Uuid();
        String defaultUsername = 'User_${uuid.v4()}';
        Timestamp defaultBirthDate = Timestamp.fromDate(DateTime.now());
        String defaultGender = Gender.Other.toString().split('.').last;

        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
          'userName': defaultUsername,
          'birthDate': defaultBirthDate,
          'gender': defaultGender,
          'createdAt': DateTime.now(),
        });

        await prefs.setString('uid', user.uid);
        await prefs.setString('userName', defaultUsername);
        await prefs.setString(
            'birthDate', defaultBirthDate.toDate().toIso8601String());
        await prefs.setString('gender', defaultGender);
        await prefs.setString('photoUrl', user.photoURL ?? '');
        await prefs.setString('userEmail', user.email ?? '');
        await prefs.setString('createdAt', DateTime.now().toIso8601String());
      } else {
        await fetchAndStoreUserDetails(user.uid);
      }

      // Update login status
      await prefs.setBool('isLoggedIn', true);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> signInWithGoogle({
    required BuildContext context,
    required Function(String) showErrorDialog,
  }) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (!docSnapshot.exists) {
          await signUpWithGoogle(
              context: context, showErrorDialog: showErrorDialog);
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', user.email ?? '');
          await fetchAndStoreUserDetails(user.uid);
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      showErrorDialog(e.message ?? 'An error occurred. Please try again.');
    }
  }

  //HELPERS
  Future<void> fetchAndStoreUserDetails(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      Map<String, dynamic> userDetails = userDoc.data() as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'birthDate',
          (userDetails['birthDate'] as Timestamp).toDate().toIso8601String() ??
              'Not available');
      await prefs.setString('gender', userDetails['gender'] ?? 'Not available');
      await prefs.setString('photoUrl', userDetails['photoUrl'] ?? '');
      await prefs.setString(
          'userName', userDetails['userName'] ?? 'Not available');
      await prefs.setString(
          'userEmail', userDetails['email'] ?? 'Not available');
      await prefs.setString('uid', userId);
    }
  }

  Future<UserModel> fetchUserDetails(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      Map<String, dynamic> userDetails = userDoc.data() as Map<String, dynamic>;
      userDetails['id'] =
          userDoc.id; // Include the user ID in the userDetails map
      print(userDetails);
      return UserModel.fromMap(userDetails);
    } else {
      return UserModel.empty();
    }
  }

  Future<String> checkRelationshipStatus(String viewerId, String userId) async {
    // Check if there's a friend request from viewer to the user
    var sentRequest = await _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: viewerId)
        .where('receiverId', isEqualTo: userId)
        .limit(1)
        .get();

    if (sentRequest.docs.isNotEmpty) {
      // Assuming 'status' field exists and can be 'pending', 'accepted', etc.
      return sentRequest.docs.first.data()['status'].toString();
    }

    // Check if there's a friend request from the user to the viewer
    var receivedRequest = await _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: userId)
        .where('receiverId', isEqualTo: viewerId)
        .limit(1)
        .get();

    if (receivedRequest.docs.isNotEmpty) {
      return receivedRequest.docs.first.data()['status'].toString();
    }

    // Check if they are already friends, assuming a 'friends' collection exists
    var friends = await _firestore
        .collection('friends')
        .where('userIds', arrayContainsAny: [viewerId, userId])
        .limit(1)
        .get();

    if (friends.docs.isNotEmpty) {
      return 'friends';
    }

    return 'none'; // No relationship found
  }
}

enum Gender { Male, Female, Other }
