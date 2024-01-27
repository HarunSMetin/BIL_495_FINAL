import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/pages/search/helperSearchFunc.dart';
import 'package:gezbot/pages/travel/travel_info.dart';

class DestinationView extends StatefulWidget {
  @override
  State<DestinationView> createState() => _DestinationViewState();
}

class _DestinationViewState extends State<DestinationView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          buildSearchForm(context),
          SearchView(),
        ],
      ),
    );
  }

  Widget SearchView() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state == SearchState.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state == SearchState.loaded) {
          // Render the list of users
          return buildSearchResults();
        } else if (state == SearchState.error) {
          return Center(
            child: Text('Error fetching Travels. Please try again.'),
          );
        } else
          return Text('Please enter a query to begin');
      },
    );
  }

  Widget buildSearchForm(BuildContext context) {
    final searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: (value) {
              // Trigger the search using the entered query
              final query = searchController.text;
              context.read<SearchBloc>().searchTravelByDestination(query);
            },
            decoration: InputDecoration(
              hintText: 'Search for destinations',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  // Trigger the search using the entered query
                  final query = searchController.text;
                  context.read<SearchBloc>().searchTravelByDestination(query);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchResults() {
    return Expanded(
      child: ListView.builder(
        itemCount: context.read<SearchBloc>().travelsByDestinationSearch.length,
        itemBuilder: (context, index) {
          Travel travel =
              context.read<SearchBloc>().travelsByDestinationSearch[index];
          return ListTile(
            title: Text(travel.name),
            subtitle: Text(travel.desiredDestination),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TravelInformation(
                    travel: travel,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
