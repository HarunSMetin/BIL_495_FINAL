import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId:
          "1027985224810-jeioofe75dtanigd4r1vtgv4v4glemis.apps.googleusercontent.com");

  Future<void> registerUser({
    required String email,
    required String password,
    required String username,
    DateTime? birthDate,
    required Gender gender, // Assuming Gender is an enum
    String? imagePath, // Local file path for the image
    required Function(String) showErrorDialog,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String photoUrl = '';
      if (imagePath != null) {
        File imageFile = File(imagePath);
        String fileName = 'user_images/${userCredential.user!.uid}/profile.jpg';

        try {
          TaskSnapshot taskSnapshot =
              await _storage.ref(fileName).putFile(imageFile);
          photoUrl = await taskSnapshot.ref.getDownloadURL();
        } on FirebaseException catch (e) {
          showErrorDialog('Failed to upload image: ${e.message}');
          return;
        }
      }

      DateTime now = DateTime.now();
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'photoUrl': photoUrl,
        'username': username,
        'birthDate': birthDate?.toIso8601String(),
        'gender': gender.toString().split('.').last,
        'createdAt': now.toIso8601String(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', username);
      await prefs.setString('photoUrl', photoUrl);
      await prefs.setString('birthDate', birthDate!.toIso8601String());
      await prefs.setString('gender', gender.toString().split('.').last);

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showErrorDialog('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showErrorDialog('An account already exists for that email.');
      } else {
        showErrorDialog(e.message ?? 'An error occurred. Please try again.');
      }
    } catch (e) {
      showErrorDialog('An error occurred. Please try again.');
    }
  }

  Future<void> signUpWithGoogle({
    required Function(String) showErrorDialog,
    required BuildContext context,
  }) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return; // User cancelled the sign-in process
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

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
}

enum Gender { Male, Female, Other }
