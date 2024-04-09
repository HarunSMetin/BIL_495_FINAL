import 'package:flutter/material.dart';
import 'package:gezbot/models/user.model.dart';

class UserProfileHeader extends StatelessWidget {
  final UserModel user;

  const UserProfileHeader({Key? key, required this.user}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      /*
      decoration: BoxDecoration(
        color: Colors.white, // White background color
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Shadow with reduced opacity
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3), // Changes position of shadow
          ),
        ],
      ),
      */
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: MediaQuery.of(context).size.width / 8,
            backgroundImage: NetworkImage(user.photoUrl),
            backgroundColor: Colors
                .transparent, // Transparent background to emphasize the image
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.userName,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Keep text color dark for contrast
                  ),
                  overflow:
                      TextOverflow.ellipsis, // Ensures text doesn't overflow
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black45, // Grey for less emphasis
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Age: ${_calculateAge(user.birthDate)}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black45, // Consistent text styling
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Gender: ${user.gender}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black45, // Consistent text styling
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
