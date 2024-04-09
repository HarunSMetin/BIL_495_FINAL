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
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade300, Colors.green.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                    icon: Icon(Icons.supervised_user_circle_sharp),
                    text: 'Users'),
                Tab(icon: Icon(Icons.airplanemode_active), text: 'Travel'),
                Tab(icon: Icon(Icons.map), text: 'Destination'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [SearchView(), TravelView(), DestinationView()],
          ),
        ),
      ),
    );
  }
}
