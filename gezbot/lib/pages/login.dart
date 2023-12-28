import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gezbot/services/database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(clientId: "1027985224810-jeioofe75dtanigd4r1vtgv4v4glemis.apps.googleusercontent.com");

  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _signIn() async {
    try {
      setState(() => _isLoading = true);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: _email, password: _password);
      User? user = userCredential.user;

      // Save logged-in state and email
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', user?.email ?? '');
      await prefs.setString('userName', user?.displayName ?? 'Not available');
      await prefs.setString('userPhotoUrl', user?.photoURL ?? '');

      Navigator.pushReplacementNamed(context, '/home'); // Navigate to home after login
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _isLoading = true);

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // User cancelled the sign-in process
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      // Save logged-in state and user details
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', user?.email ?? '');
      await prefs.setString('userName', user?.displayName ?? 'Not available');
      await prefs.setString('userPhotoUrl', user?.photoURL ?? '');

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String? message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error occurred'),
        content: Text(message ?? 'Unknown error'),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            BackButton(onPressed: () => Navigator.pushReplacementNamed(context, '/register')),
            Text('Login'),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) {
                _email = value.trim();
              },
            ),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
              onChanged: (value) {
                _password = value.trim();
              },
            ),
            SizedBox(height: 20),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                child: Text('Login'),
                onPressed: _signIn,
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
                    icon: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png', // Replace with the actual URL of the Google icon
                      height: 24.0, // Adjust the size as needed
                    ),
                    label: Text('Sign in with Google'),
                    onPressed: _signInWithGoogle,
                  ),
          ],
        ),
      ),
    );
  }
}
