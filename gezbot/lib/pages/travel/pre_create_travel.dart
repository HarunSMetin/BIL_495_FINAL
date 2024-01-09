import 'package:flutter/material.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/models/travel.model.dart';

class PreTravelCreation extends StatefulWidget {
  // Making `hasExistingTravel` non-nullable with a default value
  final Travel? travel;

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
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.travel != null) {
      _isCompleted = widget.travel!.isCompleted;
    }
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
          if (_isCompleted)
            ElevatedButton(
              onPressed: () => _continueTravel(),
              child: Text("Continue"),
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
      // Logic for creating a new travel goes here
      setState(() {
        _errorText = null;
      });
      Navigator.of(context)
          .pop(); // Close the dialog after creating a new travel
    }
  }

  void _continueTravel() {
    // Logic for continuing an existing travel goes here
    Navigator.of(context)
        .pop(); // Close the dialog after continuing existing travel
  }
}
