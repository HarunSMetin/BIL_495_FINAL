import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:gezbot/services/user_service.dart';

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
  String _confirmPassword = '';
  Gender? _gender = Gender.Other;
  String _username = '';
  DateTime? _birthDate;
  final UserService _userService = UserService(); // Instance of UserService

  bool _isLoading = false;
  XFile? _imageFile;

  void _pickBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _register() async {
    try {
      setState(() => _isLoading = true);

      await _userService.registerUser(
        email: _email,
        password: _password,
        confirmPassword: _confirmPassword,
        username: _username,
        birthDate: _birthDate,
        gender: _gender!,
        imagePath: _imageFile?.path,
        showErrorDialog: _showErrorDialog,
        context: context,
      );
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void printWarning(String text) {
    print('\x1B[33m$text\x1B[0m');
  }

  void printError(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  Future<void> _signUpWithGoogle() async {
    try {
      setState(() => _isLoading = true);
      await _userService.signUpWithGoogle(
        showErrorDialog: _showErrorDialog,
        context: context,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: (_imageFile != null)
                    ? Image.file(File(_imageFile!.path),
                        height: MediaQuery.of(context).size.height / 4)
                    : Image.network(
                        "https://w7.pngwing.com/pngs/178/595/png-transparent-user-profile-computer-icons-login-user-avatars-thumbnail.png",
                        height: MediaQuery.of(context).size.height / 4),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Select Photo'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (value) => _username = value.trim(),
              ),
              ListTile(
                title: Text(
                    "Birth Date: ${_birthDate?.toLocal().toString().split(' ')[0] ?? 'Not set'}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickBirthDate(context),
              ),
              ListTile(
                title: const Text('Male'),
                leading: Radio<Gender>(
                  value: Gender.Male,
                  groupValue: _gender,
                  onChanged: (Gender? value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Female'),
                leading: Radio<Gender>(
                  value: Gender.Female,
                  groupValue: _gender,
                  onChanged: (Gender? value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Other'),
                leading: Radio<Gender>(
                  value: Gender.Other,
                  groupValue: _gender,
                  onChanged: (Gender? value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  _email = value.trim();
                },
                // Add email validation
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                onChanged: (value) {
                  _password = value.trim();
                },
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                onChanged: (value) => _confirmPassword = value.trim(),
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    ElevatedButton(
                      child: const Text('Register'),
                      onPressed: _register,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Sign up with Google'),
                      onPressed: _signUpWithGoogle,
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Already have an account? Log in',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
