import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'components/center_widget/center_widget.dart';
import 'components/login_content.dart';

enum Gender { Male, Female, Other }

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId:
          "1027985224810-jeioofe75dtanigd4r1vtgv4v4glemis.apps.googleusercontent.com");
  final ImagePicker _picker = ImagePicker();

  String _email = '';
  String _password = '';
  // String _confirmPassword = '';
  //Gender? _gender = Gender.Male;
  String _username = '';
  // DateTime? _birthDate;

  bool _isLoading = false;
  XFile? _imageFile;

  // void _pickBirthDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(1900),
  //     lastDate: DateTime.now(),
  //   );
  //   if (picked != null && picked != _birthDate) {
  //     setState(() {
  //       _birthDate = picked;
  //     });
  //   }
  // }

  void _register() async {
    try {
      // setState(() => _isLoading = true);
      // if (_password != _confirmPassword) {
      //   _showErrorDialog('Passwords do not match.');
      //   return;
      // }
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: _email, password: _password);

      String photoUrl = ''; // Default image URL
      if (_imageFile != null) {
        File imageFile = File(_imageFile!.path);
        String fileName = 'user_images/${userCredential.user!.uid}/profile.jpg';

        try {
          TaskSnapshot taskSnapshot =
              await _storage.ref(fileName).putFile(imageFile);
          photoUrl = await taskSnapshot.ref.getDownloadURL();
        } on FirebaseException catch (e) {
          _showErrorDialog('Failed to upload image: ${e.message}');
          return;
        }
      } else {
        photoUrl =
            'https://w7.pngwing.com/pngs/178/595/png-transparent-user-profile-computer-icons-login-user-avatars-thumbnail.png'; // Replace with your default image URL
      }

      DateTime now = DateTime.now();
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': _email,
        'photoUrl': photoUrl,
        'username': _username,
        // 'birthDate': _birthDate?.toIso8601String(),
        // 'gender': _gender.toString().split('.').last,
        'createdAt': now.toIso8601String(), // Store the creation time
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', _email);

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showErrorDialog('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showErrorDialog('An account already exists for that email.');
      } else {
        _showErrorDialog(e.message);
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    try {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
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
            'username': defaultUsername,
            'birthDate': defaultBirthDate,
            'gender': defaultGender,
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userName', defaultUsername);
          await prefs.setString('birthDate', defaultBirthDate);
          await prefs.setString('gender', defaultGender);
          await prefs.setString('photoUrl', user.photoURL ?? '');
          await prefs.setString('userEmail', user.email ?? '');
        }

        // Update login status
        await prefs.setBool('isLoggedIn', true);
      }
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    /*var permissionStatus = await Permission.photos.status;
  
  if (!permissionStatus.isGranted) {
    await Permission.photos.request();
    permissionStatus = await Permission.photos.status;
  }

  if (permissionStatus.isGranted) {*/
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        if (_imageFile != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image Selected Successfully')),
          );
        }
      });
    }
    /*} else {
    _showErrorDialog('Gallery access is needed to select an image');
  }*/
  }

  void _showErrorDialog(String? message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An error occurred'),
        content: Text(message ?? 'Unknown error'),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Widget topWidget(double screenWidth) {
    return Transform.rotate(
      angle: -35 * math.pi / 180,
      child: Container(
        width: 1.2 * screenWidth,
        height: 1.2 * screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          gradient: const LinearGradient(
            begin: Alignment(-0.2, -0.8),
            end: Alignment.bottomCenter,
            colors: [
              Color(0x007CBFCF),
              Color(0xB316BFC4),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomWidget(double screenWidth) {
    return Container(
      width: 1.5 * screenWidth,
      height: 1.5 * screenWidth,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(0.6, -1.1),
          end: Alignment(0.7, 0.8),
          colors: [
            Color(0xDB4BE8CC),
            Color(0x005CDBCF),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -160,
            left: -30,
            child: topWidget(screenSize.width),
          ),
          Positioned(
            bottom: -180,
            left: -40,
            child: bottomWidget(screenSize.width),
          ),
          CenterWidget(size: screenSize),
          const LoginContent(),
        ],
      ),
    );
  }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         resizeToAvoidBottomInset: false,
//         appBar: AppBar(
//           title: const Text('Register'),
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0),
//                 child: (_imageFile != null)
//                     ? Image.file(File(_imageFile!.path),
//                         height: MediaQuery.of(context).size.height / 4)
//                     : Image.network(
//                         "https://w7.pngwing.com/pngs/178/595/png-transparent-user-profile-computer-icons-login-user-avatars-thumbnail.png",
//                         height: MediaQuery.of(context).size.height / 4),
//               ),
//               // ElevatedButton(
//               //   onPressed: _pickImage,
//               //   child: const Text('Select Photo'),
//               // ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Username'),
//                 onChanged: (value) => _username = value.trim(),
//               ),
//               // ListTile(
//               //   title: Text(
//               //       "Birth Date: ${_birthDate?.toLocal().toString().split(' ')[0] ?? 'Not set'}"),
//               //   trailing: Icon(Icons.calendar_today),
//               //   onTap: () => _pickBirthDate(context),
//               // ),
//               // ListTile(
//               //   title: const Text('Male'),
//               //   leading: Radio<Gender>(
//               //     value: Gender.Male,
//               //     groupValue: _gender,
//               //     onChanged: (Gender? value) {
//               //       setState(() {
//               //         _gender = value;
//               //       });
//               //     },
//               //   ),
//               // ),
//               // ListTile(
//               //   title: const Text('Female'),
//               //   leading: Radio<Gender>(
//               //     value: Gender.Female,
//               //     groupValue: _gender,
//               //     onChanged: (Gender? value) {
//               //       setState(() {
//               //         _gender = value;
//               //       });
//               //     },
//               //   ),
//               // ),
//               // ListTile(
//               //   title: const Text('Other'),
//               //   leading: Radio<Gender>(
//               //     value: Gender.Other,
//               //     groupValue: _gender,
//               //     onChanged: (Gender? value) {
//               //       setState(() {
//               //         _gender = value;
//               //       });
//               //     },
//               //   ),
//               // ),
//               TextFormField(
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 onChanged: (value) {
//                   _email = value.trim();
//                 },
//                 // Add email validation
//                 validator: (value) {
//                   if (value!.isEmpty || !value.contains('@')) {
//                     return 'Please enter a valid email address.';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: 'Password'),
//                 onChanged: (value) {
//                   _password = value.trim();
//                 },
//                 validator: (value) {
//                   if (value!.isEmpty || value.length < 6) {
//                     return 'Password must be at least 6 characters long.';
//                   }
//                   return null;
//                 },
//               ),
//               // TextFormField(
//               //   obscureText: true,
//               //   decoration:
//               //       const InputDecoration(labelText: 'Confirm Password'),
//               //   onChanged: (value) => _confirmPassword = value.trim(),
//               //   validator: (value) {
//               //     if (value!.isEmpty || value.length < 6) {
//               //       return 'Password must be at least 6 characters long.';
//               //     }
//               //     return null;
//               //   },
//               // ),
//               const SizedBox(height: 20),
//               if (_isLoading)
//                 const Center(child: CircularProgressIndicator())
//               else
//                 Column(
//                   children: [
//                     ElevatedButton(
//                       child: const Text('Register'),
//                       onPressed: _register,
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.login),
//                       label: const Text('Sign up with Google'),
//                       onPressed: _signUpWithGoogle,
//                     ),
//                   ],
//                 ),
//               const SizedBox(height: 20),
//               Center(
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.pushReplacementNamed(context, '/login');
//                   },
//                   child: const Text(
//                     'Already have an account? Log in',
//                     style: TextStyle(
//                       color: Colors.blue,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ));
//   }
}
