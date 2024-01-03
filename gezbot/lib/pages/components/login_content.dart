import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:gezbot/utils/helper_functions.dart';

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

import '../../../utils/constants.dart';
import '../animations/change_screen_animation.dart';
import 'bottom_text.dart';
import 'top_text.dart';

enum Gender { Male, Female, Other, Huseying }

enum Screens {
  createAccount,
  welcomeBack,
}

class LoginContent extends StatefulWidget {
  const LoginContent({Key? key}) : super(key: key);

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent>
    with TickerProviderStateMixin {
  late final List<Widget> createAccountContent;
  late final List<Widget> loginContent;

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

  //Tum inputlari burada

  Widget inputField(String hint, IconData iconData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
      child: SizedBox(
        height: 50,
        child: Material(
          elevation: 8,
          shadowColor: Colors.black87,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: TextField(
            textAlignVertical: TextAlignVertical.bottom,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: hint,
              prefixIcon: Icon(iconData),
            ),
          ),
        ),
      ),
    );
  }

  Widget loginButton(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 135, vertical: 16),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: const StadiumBorder(),
          primary: kSecondaryColor,
          elevation: 8,
          shadowColor: Colors.black87,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget orDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 8),
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 1,
              color: kPrimaryColor,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'or',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Container(
              height: 1,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget logos() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Image.asset('assets/images/facebook.png'),
          const SizedBox(width: 24),
          ElevatedButton.icon(
            icon: Image.asset(
              'assets/images/google.png',
              width: 24, // Replace with your desired width
              height: 24, // Replace with your desired height
            ),
            label: const Text('Sign up with Google'),
            onPressed: _signUpWithGoogle,
          )
        ],
      ),
    );
  }

  Widget forgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 110),
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kSecondaryColor,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    createAccountContent = [
      inputField('Username', Ionicons.person_outline),
      inputField('Email', Ionicons.mail_outline),
      inputField('Password', Ionicons.lock_closed_outline),
      loginButton('Sign Up'),
      orDivider(),
      logos(),
    ];

    loginContent = [
      inputField('Email', Ionicons.mail_outline),
      inputField('Password', Ionicons.lock_closed_outline),
      loginButton('Log In'),
      forgotPassword(),
    ];

    ChangeScreenAnimation.initialize(
      vsync: this,
      createAccountItems: createAccountContent.length,
      loginItems: loginContent.length,
    );

    for (var i = 0; i < createAccountContent.length; i++) {
      createAccountContent[i] = HelperFunctions.wrapWithAnimatedBuilder(
        animation: ChangeScreenAnimation.createAccountAnimations[i],
        child: createAccountContent[i],
      );
    }

    for (var i = 0; i < loginContent.length; i++) {
      loginContent[i] = HelperFunctions.wrapWithAnimatedBuilder(
        animation: ChangeScreenAnimation.loginAnimations[i],
        child: loginContent[i],
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    ChangeScreenAnimation.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 136,
          left: 24,
          child: TopText(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: createAccountContent,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: loginContent,
              ),
            ],
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: BottomText(),
          ),
        ),
      ],
    );
  }
}
