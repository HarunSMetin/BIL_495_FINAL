import 'package:flutter/material.dart';

class TravelQuestion extends StatefulWidget {
  @override
  _TravelQuestionState createState() => _TravelQuestionState();
}

class _TravelQuestionState extends State<TravelQuestion> {
  String _departureLocation = '';
  String _destinationLocation = '';
  DateTime _departureDate = DateTime.now();
  DateTime _returnDate = DateTime.now().add(Duration(days: 7));
  int _travelersCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan Your Trip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where do you want to go?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _departureLocation = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Departure',
                hintText: 'Enter departure location',
                prefixIcon: Icon(Icons.flight_takeoff),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _destinationLocation = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Destination',
                hintText: 'Enter destination location',
                prefixIcon: Icon(Icons.flight_land),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'When do you want to travel?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('Departure Date'),
                    subtitle: Text(
                      '${_departureDate.day}/${_departureDate.month}/${_departureDate.year}',
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _departureDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (pickedDate != null && pickedDate != _departureDate) {
                        setState(() {
                          _departureDate = pickedDate;
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('Return Date'),
                    subtitle: Text(
                      '${_returnDate.day}/${_returnDate.month}/${_returnDate.year}',
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _returnDate,
                        firstDate: _departureDate,
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (pickedDate != null && pickedDate != _returnDate) {
                        setState(() {
                          _returnDate = pickedDate;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'How many travelers?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_travelersCount > 1) {
                        _travelersCount--;
                      }
                    });
                  },
                ),
                Text(
                  '$_travelersCount',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _travelersCount++;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Perform search or navigate to the next screen with the provided details.
                // You can customize this based on your app's logic.
                // For now, let's print the details to the console.
                print('Departure: $_departureLocation');
                print('Destination: $_destinationLocation');
                print('Departure Date: $_departureDate');
                print('Return Date: $_returnDate');
                print('Travelers Count: $_travelersCount');
              },
              child: Text('Search Flights'),
            ),
          ],
        ),
      ),
    );
  }
}
