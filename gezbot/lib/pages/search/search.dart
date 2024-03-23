import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gezbot/pages/search/destinationSearch.dart';
import 'package:gezbot/pages/search/travelSearch.dart';
import 'package:gezbot/pages/search/userSearch.dart';
import 'package:gezbot/pages/search/helperSearchFunc.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(
                    icon: Icon(Icons.supervised_user_circle_sharp),
                    text: 'Search Users'),
                Tab(icon: Icon(Icons.airplanemode_active), text: 'Travel'),
                Tab(icon: Icon(Icons.map), text: 'Destination'),
              ],
            ),
          ),
          body: TabBarView(
            children: [SearchView(), TravelView(), const DestinationView()],
          ),
        ),
      ),
    );
  }
}
