// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:gezbot/services/user_service.dart'; // Import UserService

// class ProfilePage extends StatefulWidget {
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final UserService _userService = UserService(); // Instance of UserService
//   late Future<Map<String, String>> userDetailsFuture;
//   XFile? _imageFile;
//   @override
//   void initState() {
//     super.initState();
//     userDetailsFuture = _getUserDetails();
//   }

//   int _calculateAge(String birthDateString) {
//     if (birthDateString == 'Not available') {
//       return -1; // Indicates age is not available
//     }

//     DateTime birthDate = DateTime.parse(birthDateString);
//     DateTime currentDate = DateTime.now();
//     int age = currentDate.year - birthDate.year;
//     if (birthDate.month > currentDate.month ||
//         (birthDate.month == currentDate.month &&
//             birthDate.day > currentDate.day)) {
//       age--;
//     }

//     return age;
//   }

//   Future<Map<String, String>> _getUserDetails() async {
//     final prefs = await SharedPreferences.getInstance();
//     String userEmail = prefs.getString('userEmail') ?? 'Not available';
//     String userName = prefs.getString('userName') ?? 'Not available';
//     String userPhotoUrl = prefs.getString('photoUrl') ?? '';
//     String userBirthDate = prefs.getString('birthDate') ?? 'Not available';
//     String userGender = prefs.getString('gender') ?? 'Not available';

//     return {
//       'email': userEmail,
//       'name': userName,
//       'photoUrl': userPhotoUrl,
//       'birthDate': userBirthDate,
//       'gender': userGender,
//     };
//   }

//   Future<void> _refreshUserDetails() async {
//     setState(() {
//       _getUserDetails();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     void _showErrorDialog(String? message) {
//       showDialog(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           title: const Text('An error occurred'),
//           content: Text(message ?? 'Unknown error'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Okay'),
//               onPressed: () {
//                 Navigator.of(ctx).pop();
//               },
//             )
//           ],
//         ),
//       );
//     }

//     void logout() async {
//       final GoogleSignIn googleSignIn = GoogleSignIn(
//           clientId:
//               "1027985224810-jeioofe75dtanigd4r1vtgv4v4glemis.apps.googleusercontent.com");
//       final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//       await googleSignIn.signOut();
//       await firebaseAuth.signOut();
//       Navigator.pushReplacementNamed(context, '/login');
//     }

//     void _updateProfile(
//         BuildContext context, String field, String userId) async {
//       TextEditingController _controller = TextEditingController();
//       late Future<void> Function() updateFunction;

//       switch (field) {
//         case 'username':
//           updateFunction = () async {
//             await _userService.updateUsername(
//                 userId: userId, username: _controller.text);
//             await _refreshUserDetails();
//           };
//           break;
//         case 'birth date':
//           updateFunction = () async {
//             DateTime? selectedDate = await showDatePicker(
//               context: context,
//               initialDate: DateTime.now(),
//               firstDate: DateTime(1900),
//               lastDate: DateTime.now(),
//             );
//             if (selectedDate != null) {
//               await _userService.updateUserBirthDate(
//                   userId: userId, birthDate: selectedDate);
//               await _refreshUserDetails();
//             }
//           };
//           break;
//         case 'gender':
//           updateFunction = () async {
//             String? selectedGender = await showDialog<String>(
//               context: context,
//               builder: (BuildContext context) {
//                 return SimpleDialog(
//                   title: const Text('Select Gender'),
//                   children: <Widget>[
//                     SimpleDialogOption(
//                       onPressed: () {
//                         Navigator.pop(context, 'Male');
//                       },
//                       child: const Text('Male'),
//                     ),
//                     SimpleDialogOption(
//                       onPressed: () {
//                         Navigator.pop(context, 'Female');
//                       },
//                       child: const Text('Female'),
//                     ),
//                     // Add more options here if needed
//                   ],
//                 );
//               },
//             );
//             if (selectedGender != null) {
//               await _userService.updateGender(
//                   userId: userId, gender: selectedGender);
//               await _refreshUserDetails();
//             }
//           };
//           break;
//         // ... other cases
//       }

//       if (field != 'birth date' && field != 'gender') {
//         showDialog(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               title: Text('Update $field'),
//               content: TextField(
//                 controller: _controller,
//                 decoration: InputDecoration(hintText: "Enter new $field"),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   child: Text('Cancel'),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//                 TextButton(
//                   child: Text('Update'),
//                   onPressed: () async {
//                     await updateFunction();
//                     await _refreshUserDetails();
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       } else {
//         await updateFunction();
//       }
//     }

//     Future<void> _pickImage() async {
//       final pickedFile =
//           await ImagePicker().pickImage(source: ImageSource.gallery);

//       if (pickedFile != null) {
//         setState(() => _imageFile = pickedFile);

//         try {
//           await _userService.updateUserProfilePhoto(
//             userId: FirebaseAuth.instance.currentUser?.uid ?? '',
//             imagePath: _imageFile!.path,
//             showErrorDialog: _showErrorDialog,
//           );
//           // Refresh the profile
//           await _refreshUserDetails();
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Image Updated Successfully')));
//         } catch (e) {
//           _showErrorDialog('Failed to update image: ${e.toString()}');
//         }
//       }
//     }

//     String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
//     return RefreshIndicator(
//       onRefresh: _refreshUserDetails,
//       child: SingleChildScrollView(
//         physics: AlwaysScrollableScrollPhysics(),
//         child: FutureBuilder<Map<String, String>>(
//           future: _getUserDetails(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               return SafeArea(
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       Padding(
//                         padding: EdgeInsets.fromLTRB(
//                             MediaQuery.of(context).size.width / 4,
//                             MediaQuery.of(context).size.height / 5,
//                             MediaQuery.of(context).size.width / 4,
//                             0), // Adjust the value as needed
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Flexible(
//                               child: Text(
//                                 '${snapshot.data?['name'] ?? 'Not available'}',
//                                 style: TextStyle(fontSize: 20),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.edit),
//                               onPressed: () =>
//                                   _updateProfile(context, 'username', userId),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       if (snapshot.data?['photoUrl'] != '')
//                         Stack(
//                           alignment: Alignment.bottomRight,
//                           children: [
//                             CircleAvatar(
//                               backgroundImage:
//                                   NetworkImage(snapshot.data!['photoUrl']!),
//                               radius: MediaQuery.of(context).size.width / 5,
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.camera_alt),
//                               onPressed: _pickImage,
//                               color: Theme.of(context).primaryColor,
//                               iconSize: 30,
//                             ),
//                           ],
//                         ),
//                       SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Age: ${_calculateAge(snapshot.data?['birthDate'] ?? 'Not available') != -1 ? _calculateAge(snapshot.data?['birthDate'] ?? 'Not available').toString() : 'Not available'}',
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.edit),
//                             onPressed: () =>
//                                 _updateProfile(context, 'birth date', userId),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                               'Gender: ${snapshot.data?['gender'] ?? 'Not available'}'),
//                           IconButton(
//                             icon: Icon(Icons.edit),
//                             onPressed: () =>
//                                 _updateProfile(context, 'gender', userId),
//                           ),
//                         ],
//                       ),
//                       ElevatedButton(
//                         onPressed: logout,
//                         child: Text('Logout'),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             } else {
//               return Center(child: CircularProgressIndicator());
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ProfilePage2 extends StatefulWidget {
  const ProfilePage2({super.key});

  @override
  State<ProfilePage2> createState() => _ProfilePage2State();
}

class _ProfilePage2State extends State<ProfilePage2> {
  bool isEditing = false;

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
          child: const Text('User Name'),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 75,
                    backgroundImage: NetworkImage(
                      'https://t3.ftcdn.net/jpg/06/04/79/52/360_F_604795233_5zIpEvhWizTN7bUxSADUdrQQFGj315G3.jpg',
                    ),
                  ),
                  const SizedBox(
                      width: 20), // Add some space between image and stats
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical:
                                  8.0), // Adjust the vertical space between rows
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            height:
                                20), // Adding space between the statistics and the text boxes
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical:
                                  8.0), // Adjust the vertical space between rows
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTextBox(
                                  "Age", "18"), // Replace with actual age
                              _buildTextBox("Gender",
                                  "Male"), // Replace with actual gender
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20), // Add space between stats and buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.4, // Set the button width
                  height: 50, // Set the button height
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Set button shape
                      ),
                    ),
                    onPressed: () {
                      // Implement edit profile functionality
                    },
                    child: const Text('Edit Profile'),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.4, // Set the button width
                  height: 50, // Set the button height
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Set button shape
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
      padding: const EdgeInsets.all(8.0),
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
          return ListTile(
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
