import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/pages/chatInfo/chatInfo.dart';
import 'firebase_options.dart';
import 'pages/login_screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/homepage.dart';

<<<<<<< HEAD
import 'utils/constants.dart';

=======
>>>>>>> 7de1de7662b6b44ed7fa4f0335512cdf4860bbe6
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(
      title: 'Traivel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: kPrimaryColor,
              fontFamily: 'Montserrat',
            ),
      ),
      home: isLoggedIn ? HomePage() : RegisterScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomePage(),
      },
=======
    return SafeArea(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: widget.isLoggedIn ? HomePage() : LoginScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomePage(),
          '/chatInfo': (context) => ChatInfo(
                travelInfo:
                    ModalRoute.of(context)!.settings.arguments as Travel? ??
                        Travel.empty(),
              ),
        },
      ),
>>>>>>> 7de1de7662b6b44ed7fa4f0335512cdf4860bbe6
    );
  }
}
