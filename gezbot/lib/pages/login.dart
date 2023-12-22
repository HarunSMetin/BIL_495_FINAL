import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _signIn() async {
    try {
      setState(() => _isLoading = true);
      await _auth.signInWithEmailAndPassword(email: _email, password: _password);
      print('Signed in');

      // Save logged-in state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacementNamed(context, '/home'); // Navigate to home after login
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
          ],
        ),
      ),
    );
  }
}
