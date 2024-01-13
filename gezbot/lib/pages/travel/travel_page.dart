// import 'package:flutter/material.dart';
// import 'package:gezbot/services/database_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:gezbot/pages/travel/travel_info.dart';
// import 'package:gezbot/pages/travel/pre_create_travel.dart';
// import 'package:gezbot/models/travel.model.dart';

// class TravelsScreen extends StatefulWidget {
//   @override
//   _TravelsScreenState createState() => _TravelsScreenState();
// }

// class _TravelsScreenState extends State<TravelsScreen> {
//   final DatabaseService dbService = DatabaseService();
//   Future<List<Travel>>? travelsFuture;
//   final ScrollController _scrollController = ScrollController();
//   bool isFetchingMore = false;
//   late final prefs;

//   @override
//   void initState() {
//     super.initState();
//     travelsFuture = _fetchTravels();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<List<Travel>> _fetchTravels() async {
//     prefs = await SharedPreferences.getInstance();
//     String? userId = prefs.getString('uid');
//     if (userId != null) {
//       Map<String, Travel> travelsData =
//           await dbService.GetAllTravelsOfUser(userId);
//       return travelsData.values.toList();
//     } else {
//       return [];
//     }
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels ==
//             _scrollController.position.maxScrollExtent &&
//         !isFetchingMore) {
//       _refreshTravels();
//     }
//   }

//   Future<void> _refreshTravels() async {
//     setState(() {
//       isFetchingMore = true;
//     });

//     setState(() {
//       travelsFuture = _fetchTravels();
//       isFetchingMore = false;
//     });
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text('Image Updated Successfully')));
//   }

//   @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //       appBar: AppBar(title: Text('Travels')),
//   //       floatingActionButton: FloatingActionButton(
//   //         onPressed: () async {
//   //           await dbService.GetLastNotCompletedTravelOfUser(
//   //                   prefs.getString('uid'))
//   //               .then((value) {
//   //             showDialog(
//   //               context: context,
//   //               builder: (BuildContext context) {
//   //                 if (value == null) {
//   //                   return Dialog(
//   //                     child: PreTravelCreation(
//   //                       travel: Travel.empty(),
//   //                     ),
//   //                   );
//   //                 } else {
//   //                   return Dialog(
//   //                     child: PreTravelCreation(
//   //                       travel: value,
//   //                     ),
//   //                   );
//   //                 }
//   //               },
//   //             );
//   //           });
//   //         },
//   //         child: Icon(Icons.add),
//   //         tooltip: 'Add Travel',
//   //       ),
//   //       body: RefreshIndicator(
//   //         onRefresh: _refreshTravels,
//   //         child: FutureBuilder<List<Travel>>(
//   //           future: travelsFuture,
//   //           builder: (context, snapshot) {
//   //             if (snapshot.connectionState == ConnectionState.waiting) {
//   //               return Center(child: CircularProgressIndicator());
//   //             }
//   //             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//   //               return Center(child: Text('No Travels Found'));
//   //             }
//   //             if (snapshot.hasError) {
//   //               return Center(child: Text('Error: ${snapshot.error}'));
//   //             }

//   //             List<Travel> travels = snapshot.data!;
//   //             return Flex(
//   //               direction: Axis.vertical,
//   //               children: [
//   //                 Expanded(
//   //                   child: ListView.builder(
//   //                     controller: _scrollController,
//   //                     itemCount: travels.length,
//   //                     itemBuilder: (context, index) {
//   //                       Travel travel = travels[index];
//   //                       return ListTile(
//   //                         key: ValueKey(travel.id),
//   //                         title: Text(travel.name),
//   //                         subtitle: Text(travel.description),
//   //                         onTap: () {
//   //                           Navigator.push(
//   //                             context,
//   //                             MaterialPageRoute(
//   //                               builder: (context) =>
//   //                                   TravelInformation(travel: travel),
//   //                             ),
//   //                           );
//   //                         },
//   //                       );
//   //                     },
//   //                   ),
//   //                 ),
//   //               ],
//   //             );
//   //           },
//   //         ),
//   //       ));
//   // }

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'activity_details_screen.dart';

import './models/activity_model.dart';
import './widgets/custom_header.dart';

class TravelPage extends StatelessWidget {
  const TravelPage({super.key});

  static const routeName = '/activities';

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<Activity> activities = Activity.activities;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          const CustomHeader(title: 'Activities'),
          _ActivitiesMasonryGrid(
            width: width,
            activities: activities,
          ),
        ],
      ),
    );
  }
}

class _ActivitiesMasonryGrid extends StatelessWidget {
  const _ActivitiesMasonryGrid({
    Key? key,
    this.masonryCardHeights = const [200, 250, 300],
    required this.width,
    required this.activities,
  }) : super(key: key);

  final List<double> masonryCardHeights;
  final double width;
  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10.0),
      itemCount: 9,
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemBuilder: (context, index) {
        Activity activity = activities[index];
        return _buildActivityCard(
          context,
          activity,
          index,
        );
      },
    );
  }

  InkWell _buildActivityCard(
    BuildContext context,
    Activity activity,
    int index,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityDetailsScreen(activity: activity),
          ),
        );
      },
      child: Column(
        children: [
          Hero(
            tag: '${activity.id}_${activity.title}',
            child: Container(
              height: masonryCardHeights[index % 3],
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                image: DecorationImage(
                  image: NetworkImage(activity.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            activity.title,
            maxLines: 3,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
