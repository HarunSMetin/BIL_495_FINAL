import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:gezbot/pages/profile/profile_page.dart';
import 'package:gezbot/pages/search/search.dart';
import 'package:gezbot/pages/travel/travel_page.dart';
import 'package:gezbot/pages/login_screen/components/center_widget/center_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gezbot/pages/home/travels_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _topAnimation;
  late Animation<Offset> _bottomAnimation;
  final Future<String> _uidFuture = _fetchUID(); // Initialize immediately

  static Future<String> _fetchUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid') ?? '';
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _topAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(math.Random().nextDouble(), math.Random().nextDouble()),
    ).animate(_animationController);

    _bottomAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(math.Random().nextDouble(), math.Random().nextDouble()),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _animationController.forward(from: 0.0);
    });
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

  Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  int _selectedIndex = 0; // Define the selected index

  @override
  Widget build(BuildContext context) {
    Size screenSize = getScreenSize(context);

    final List<Widget> widgetOptions = [
      Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                top: _topAnimation.value.dy * screenSize.height,
                left: _topAnimation.value.dx * screenSize.width,
                child: topWidget(screenSize.width),
              );
            },
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                bottom: _bottomAnimation.value.dy * screenSize.height,
                left: _bottomAnimation.value.dx * screenSize.width,
                child: bottomWidget(screenSize.width),
              );
            },
          ),
          CenterWidget(size: screenSize), // Use screenSize here
          FutureBuilder<String>(
            future: _uidFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Text('Error fetching user data');
              }
              return TravelsWidget(userId:snapshot.data!); // Pass the user ID directly
            },
          ),
        ],
      ),
      const SearchPage(),
      FutureBuilder<String>(
        future: _uidFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Text('Error fetching user data');
          }
          return TravelsScreen(userId: snapshot.data!);
        },
      ),
      FutureBuilder<String>(
        future: _uidFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Text('Error fetching user data');
          }
          return ProfilePage(
              userId: snapshot
                  .data!); // Assuming ProfilePage accepts a userId parameter
        },
      ),
// Additional widget options if needed
    ];

    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: 'Travels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
