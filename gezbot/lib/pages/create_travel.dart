import 'package:flutter/material.dart';
import 'package:gezbot/services/database_service.dart';

class CreateTravelScreen extends StatefulWidget {
  final DatabaseService dbService;

  CreateTravelScreen({required this.dbService});

  @override
  _CreateTravelScreenState createState() => _CreateTravelScreenState();
}

class _CreateTravelScreenState extends State<CreateTravelScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Map<String, dynamic> _travelData = {};

  void _saveData(String key, dynamic value) {
    setState(() {
      _travelData[key] = value;
    });
  }

  void _goToNextPage() {
    if (_currentPage < 11) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _createTravel();
    }
  }

  void _createTravel() async {
    // Implement the logic to save the travel data using your dbService
    // For example: await widget.dbService.createTravel(_travelData);
    Navigator.pop(
        context); // Or navigate to the newly created travel's detail page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Travel')),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: <Widget>[
          //DepartureDatePage(onSave: _saveData),
          // Add other pages here...
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToNextPage,
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}
