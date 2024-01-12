import 'package:flutter/material.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:gezbot/shared/constants.dart';

class UserInfoCard extends StatefulWidget {
  const UserInfoCard({super.key, required this.user});
  final UserModel user;

  @override
  State<UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            constraints: const BoxConstraints(maxWidth: double.infinity),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 130,
                  child: Stack(
                    children: [
                      ClipPath(
                        clipper: AvatarClipper(),
                        child: Container(
                          height: 80,
                          decoration: const BoxDecoration(
                            color: darkColor,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 11,
                        top: 30,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  NetworkImage(widget.user.photoUrl),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.user.userName,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.user.email,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: darkColor,
                                  ),
                                ),
                                const SizedBox(height: 8)
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 30,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Text(
                              "Age:  ${DateTime.now().year - widget.user.birthDate.year}",
                              style: montserrat,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Text(
                              "Gender: ${widget.user.gender} ",
                              style: montserrat,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _databaseService.GetUserSummary(widget.user.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  snapshot.data!['acceptedRecived'].toString(),
                                  style: buildMontserrat(
                                    const Color(0xFF000000),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Followers",
                                  style: buildMontserrat(darkColor),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 50,
                              child: VerticalDivider(
                                color: Color(0xFF9A9A9A),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  snapshot.data!['acceptedSent'].toString(),
                                  style: buildMontserrat(
                                    const Color(0xFF000000),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Following",
                                  style: buildMontserrat(darkColor),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 50,
                              child: VerticalDivider(
                                color: Color(0xFF9A9A9A),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  snapshot.data!['travels'].toString(),
                                  style: buildMontserrat(
                                    const Color(0xFF000000),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Travels",
                                  style: buildMontserrat(darkColor),
                                )
                              ],
                            ),
                          ],
                        );
                      } else {
                        return Container(
                          height: 100,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AvatarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height)
      ..lineTo(8, size.height)
      ..arcToPoint(Offset(114, size.height), radius: const Radius.circular(1))
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
