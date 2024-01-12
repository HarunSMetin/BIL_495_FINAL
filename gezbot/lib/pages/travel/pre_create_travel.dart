import 'package:flutter/material.dart';
import 'package:gezbot/pages/travel/create_travel_form.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreTravelCreation extends StatefulWidget {
  // Making `hasExistingTravel` non-nullable with a default value
  final Travel travel;

  const PreTravelCreation({
    Key? key,
    required this.travel,
  }) : super(key: key);

  @override
  _PreTravelCreationState createState() => _PreTravelCreationState();
}

class _PreTravelCreationState extends State<PreTravelCreation> {
  final TextEditingController _travelNameController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  String? _errorText;
  bool _completedExists = false;
  late final prefs;

  @override
  void initState() {
    super.initState();
    if (widget.travel.id != 'empty') {
      _completedExists = !widget.travel.isCompleted;

      print("Completed exists: $_completedExists");
    }
    fetchPrefs();
  }

  void fetchPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Ensure the dialog is only as tall as needed
        children: <Widget>[
          TextField(
            controller: _travelNameController,
            decoration: InputDecoration(
              labelText: "Travel Name",
              errorText: _errorText,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _createNewTravel(),
            child: Text("New Travel"),
          ),
          // The Continue button is conditionally displayed
          if (_completedExists)
            ElevatedButton(
              onPressed: () => _continueTravel(),
              child: Text("Continue ${widget.travel!.name}"),
            ),
        ],
      ),
    );
  }

  void _createNewTravel() {
    if (_travelNameController.text.isEmpty) {
      setState(() {
        _errorText = "Travel name cannot be empty";
      });
    } else {
      setState(() {
        _errorText = null;
      });
      _databaseService.CreateTravel(
              prefs.getString('uid')!, _travelNameController.text)
          .then((value) {
        // Only navigate to the new screen after the future is complete
        Navigator.of(context).pop(); // Close the current screen first
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TravelQuestionnaireForm(
                    travelId: value,
                    travelName: _travelNameController.text,
                  )),
        );
      }).catchError((error) {
        // Handle any errors here
        print("Error creating travel: $error");
      });
    }
  }

  void _continueTravel() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TravelQuestionnaireForm(
          travelId: widget.travel.id,
          travelName: widget.travel.name,
        ),
      ),
    );
  }
}
