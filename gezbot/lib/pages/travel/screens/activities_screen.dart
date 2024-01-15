import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/pages/profile/profile_page.dart';
import 'package:gezbot/pages/travel/widgets/side_bar.dart';
import 'activity_details_screen.dart';

import '../models/activity_model.dart';
import '../widgets/custom_header.dart';

import 'package:gezbot/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  static const routeName = '/activities';

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final DatabaseService dbService = DatabaseService();
  Future<List<Travel>>? travelsFuture;
  final ScrollController _scrollController = ScrollController();
  bool isFetchingMore = false;
  late final prefs;

  @override
  void initState() {
    super.initState();
    travelsFuture = _fetchTravels();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Travel>> _fetchTravels() async {
    prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    if (userId != null) {
      Map<String, Travel> travelsData =
          await dbService.GetAllTravelsOfUser(userId);
      return travelsData.values.toList();
    } else {
      return [];
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isFetchingMore) {
      _refreshTravels();
    }
  }

  Future<void> _refreshTravels() async {
    setState(() {
      isFetchingMore = true;
    });

    setState(() {
      travelsFuture = _fetchTravels();
      isFetchingMore = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Image Updated Successfully')));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

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
                  const SizedBox(height: 5),
                  const CustomHeader(title: 'Travels'),
                  // FutureBuilder should be inside this part of the Column
                  FutureBuilder<List<Travel>>(
                    future: travelsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No Travels Found'));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      List<Travel> travels = snapshot.data!;
                      // Continue building your UI with travels data
                      return _ActivitiesMasonryGrid(
                        width: width,
                        travels: travels,
                      );
                    },
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
    required this.travels,
  }) : super(key: key);

  final List<double> masonryCardHeights;
  final double width;
  final List<Travel> travels;

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
        Travel travel = travels[index];
        return _buildActivityCard(
          context,
          travel,
          index,
        );
      },
    );
  }

  InkWell _buildActivityCard(
    BuildContext context,
    Travel travel,
    int index,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfilePage(),
          ),
        );
      },
      child: Column(
        children: [
          Hero(
            tag: '${travel.id}_${travel.name}',
            child: Container(
              height: masonryCardHeights[index % 3],
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://source.unsplash.com/random? travel'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            travel.name,
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
