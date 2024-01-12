import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gezbot/pages/profile/edit_profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gezbot/services/user_service.dart'; // Import UserService

//hello
//from profile branch

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  final UserService _userService = UserService(); // Instance of UserService
  late Future<Map<String, dynamic>> userDetailsFuture;
  XFile? _imageFile;
  @override
  void initState() {
    super.initState();
    userDetailsFuture = _getUserDetails();
  }

  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (birthDate.month > currentDate.month ||
        (birthDate.month == currentDate.month &&
            birthDate.day > currentDate.day)) {
      age--;
    }

    return age;
  }

  Future<Map<String, dynamic>> _getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String userEmail = prefs.getString('userEmail') ?? 'Not available';
    String userName = prefs.getString('userName') ?? 'Not available';
    String userPhotoUrl = prefs.getString('photoUrl') ?? '';
    DateTime userBirthDate = prefs.getString('birthDate') != null
        ? DateTime.parse(prefs.getString('birthDate')!)
        : DateTime.now();
    String userGender = prefs.getString('gender') ?? 'Not available';

    return {
      'email': userEmail,
      'name': userName,
      'photoUrl': userPhotoUrl,
      'birthDate': userBirthDate,
      'gender': userGender,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2FFF4),
        title: GestureDetector(
          onTap: () {
            setState(() {
              isEditing = !isEditing;
            });
          },
          child: const Text('Traveler Profile'),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: FutureBuilder(
        future:
            _getUserDetails(), // Replace _getUserDetails with your actual method
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show loading indicator while fetching data
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: MediaQuery.of(context).size.width / 8,
                              backgroundImage:
                                  NetworkImage(snapshot.data!['photoUrl']!),
                            ),
                            const SizedBox(
                                height:
                                    8), // Add some space between CircleAvatar and Text
                            Container(
                              width: MediaQuery.of(context).size.width /
                                  4, // Adjust the width as needed
                              child: Text(
                                snapshot.data?['name'] ?? 'Not available',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ), // Add some space between image and stats
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical:
                                        8.0), // Adjust the vertical space between rows
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStat("Trips",
                                        "10"), // Replace with actual trip count
                                    _buildStat("Followers",
                                        "1000"), // Replace with actual follower count
                                    _buildStat("Following",
                                        "500"), // Replace with actual following count
                                  ],
                                ),
                              ),

                              const SizedBox(
                                height: 15,
                              ), // Adding space between the statistics and the text boxes
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical:
                                        2.0), // Adjust the vertical space between rows
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // or CrossAxisAlignment.center
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: _buildTextBox(
                                          "Age",
                                          _calculateAge(snapshot
                                                          .data?['birthDate'] ??
                                                      'Not available') !=
                                                  -1
                                              ? _calculateAge(snapshot
                                                          .data?['birthDate'] ??
                                                      'Not available')
                                                  .toString()
                                              : 'Not available',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: _buildTextBox(
                                          "Gender",
                                          snapshot.data?['gender'] ??
                                              'Not available',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  const SizedBox(
                      height: 10), // Add space between stats and buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.4, // Set the button width
                        height: 35, // Set the button height
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Set button shape
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfilePage()),
                            );
                          },
                          child: const Text('Edit Profile'),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.4, // Set the button width
                        height: 35, // Set the button height
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Set button shape
                            ),
                          ),
                          onPressed: () {
                            // Implement share profile functionality
                          },
                          child: const Text('Share Profile'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStat(String title, String value) {
    return GestureDetector(
      onTap: () {
        if (title == "Followers" || title == "Following") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => _buildStatDetailed(title, int.parse(value)),
            ),
          );
        } else if (title == "Trips") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => _buildTripDetailed(context),
            ),
          );
        }
      },
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatDetailed(String title, int itemCount) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // Modify the title as needed
      ),
      body: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text('Person ${index + 1}'),
                subtitle: const Text('Member'),

                trailing: title == 'Following'
                    ? IconButton(
                        onPressed: () {
                          debugPrint('User will be unfollowed here');
                          // Add your logic here for unfollowing the user
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      )
                    : null, // If title is not 'Following', set trailing to null
              ),
              if (index < itemCount - 1)
                const Divider(), // Add a Divider for all but the last item
            ],
          );
        },
      ),
    );
  }

  Widget _buildTripDetailed(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location: Eskisehir',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Group Members: members',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Date: date',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
