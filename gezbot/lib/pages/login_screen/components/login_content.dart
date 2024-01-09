import 'package:flutter/material.dart';
import 'package:gezbot/pages/travel/travel_page.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:ionicons/ionicons.dart';
import 'package:gezbot/utils/helper_functions.dart';

import 'package:gezbot/shared/constants.dart';
import '../animations/change_screen_animation.dart';
import 'bottom_text.dart';
import 'top_text.dart';

import 'package:gezbot/services/user_service.dart';

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
  final _userService = UserService();

// Registration Controllers
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

// Login Controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  void login_or_register(
    BuildContext context,
    void Function(String) _showErrorDialog,
  ) async {
    if (ChangeScreenAnimation.currentScreen == Screens.createAccount) {
      try {
        await _userService.signUpWithGoogle(
          context: context,
          showErrorDialog: _showErrorDialog,
        );
      } catch (e) {
        printError(e.toString());
      }
    } else {
      try {
        await _userService.signInWithGoogle(
          context: context,
          showErrorDialog: _showErrorDialog,
        );
      } catch (e) {
        printError(e.toString());
      }
    }
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

  void _registerUser() async {
    // Use the _userService to register the user
    // Use _nameController.text, _emailController.text, _passwordController.text
    UserService _userService = UserService();
    try {
      await _userService.registerUser(
        email: _registerEmailController.text,
        password: _registerPasswordController.text,
        username: _nameController.text,
        showErrorDialog: _showErrorDialog,
        context: context,
      );
    } catch (e) {
      printError(e.toString());
    }
  }

  void _signInUser() async {
    // Use the _userService to sign in the user
    // Use _emailController.text, _passwordController.text
    UserService _userService = UserService();
    try {
      await _userService.signInWithEmailAndPassword(
        email: _loginEmailController.text,
        password: _loginPasswordController.text,
        showErrorDialog: _showErrorDialog,
        context: context,
      );
    } catch (e) {
      printError(e.toString());
    }
  }

  Widget inputField(
      String hint, IconData iconData, TextEditingController controller,
      {bool isPassword = false}) {
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
            controller: controller,
            obscureText: isPassword,
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
      padding: const EdgeInsets.symmetric(horizontal: 75, vertical: 16),
      child: ElevatedButton(
        onPressed: () {
          if (ChangeScreenAnimation.currentScreen == Screens.createAccount) {
            _registerUser();
          } else {
            _signInUser();
          }
        },
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
            color: Colors.white,
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
      child: Center(
        child: TextButton(
          onPressed: () {
            void _showErrorDialog(String message) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('An error occurred'),
                  content: Text(message),
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

            login_or_register(context, _showErrorDialog);
          },
          child: Image.asset('assets/images/google.png'),
        ),
        //Image.asset('assets/images/google.png'),
      ),
    );
  }

  Widget forgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 75),
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

  void printError(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  @override
  void initState() {
    createAccountContent = [
      inputField('Name', Ionicons.person_outline, _nameController),
      inputField('Email', Ionicons.mail_outline, _registerEmailController),
      inputField(
          'Password', Ionicons.lock_closed_outline, _registerPasswordController,
          isPassword: true),
      loginButton('Sign Up'),
      orDivider(),
      logos(),
    ];

    loginContent = [
      inputField('Email', Ionicons.mail_outline, _loginEmailController),
      inputField(
          'Password', Ionicons.lock_closed_outline, _loginPasswordController,
          isPassword: true),
      loginButton('Log In'),
      forgotPassword(),
      logos(),
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
    _nameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    //ChangeScreenAnimation.dispose();

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
