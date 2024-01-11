import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
      "https://w7.pngwing.com/pngs/178/595/png-transparent-user-profile-computer-icons-login-user-avatars-thumbnail.png";

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
        'username': username,
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
        String defaultBirthDate = DateTime.now().toIso8601String();
        String defaultGender = Gender.Other.toString().split('.').last;

        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
          'userName': defaultUsername,
          'birthDate': defaultBirthDate,
          'gender': defaultGender,
          'createdAt': DateTime.now().toIso8601String(),
        });

        await prefs.setString('uid', user.uid);
        await prefs.setString('userName', defaultUsername);
        await prefs.setString('birthDate', defaultBirthDate);
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
          'birthDate', userDetails['birthDate'] ?? 'Not available');
      await prefs.setString('gender', userDetails['gender'] ?? 'Not available');
      await prefs.setString('photoUrl', userDetails['photoUrl'] ?? '');
      await prefs.setString(
          'userName', userDetails['userName'] ?? 'Not available');
      await prefs.setString(
          'userEmail', userDetails['email'] ?? 'Not available');
      await prefs.setString('uid', userId);
    }
  }
}

enum Gender { Male, Female, Other }
