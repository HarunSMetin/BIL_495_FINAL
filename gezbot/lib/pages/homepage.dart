import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:gezbot/pages/profile/profile_page.dart';
import 'package:gezbot/pages/travel/activity_details_screen.dart';
import 'package:gezbot/pages/travel/travel_page.dart';
import 'package:gezbot/pages/login_screen/components/center_widget/center_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _topAnimation;
  late Animation<Offset> _bottomAnimation;
  final math.Random random = math.Random();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _topAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(random.nextDouble(), random.nextDouble()),
    ).animate(_animationController);

    _bottomAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(random.nextDouble(), random.nextDouble()),
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
      // Restart the animation with new random end values
      _topAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1),
      ).animate(_animationController);

      _bottomAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1),
      ).animate(_animationController);

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

  @override
  Widget build(BuildContext context) {
    Size screenSize = getScreenSize(context);

    final List<Widget> _widgetOptions = [
      Text('Home Tab'),
      Text('Search Tab'),
      const TravelPage(),
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
          ProfilePage(),
        ],
      ),
    ];

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
        selectedItemColor: const Color.fromARGB(255, 124, 136, 146),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
