import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gezbot/pages/travel/widgets/side_bar.dart';
import 'activity_details_screen.dart';

import '../models/activity_model.dart';
import '../widgets/custom_header.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  static const routeName = '/activities';

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    List<Activity> activities = Activity.activities;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          SideBar(
            width: width * 0.6,
            height: height,
            navigator: GlobalKey<NavigatorState>(),
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  const CustomHeader(title: 'Travels'),
                  _ActivitiesMasonryGrid(
                    width: width,
                    activities: activities,
                  ),
                ],
              ),
            ),
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
