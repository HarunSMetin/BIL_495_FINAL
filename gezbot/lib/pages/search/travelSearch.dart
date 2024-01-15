import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/pages/search/helperSearchFunc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelView extends StatefulWidget {
  @override
  State<TravelView> createState() => _TravelViewState();
}

class _TravelViewState extends State<TravelView> {
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

  static Future<String> _fetchUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid') ?? 'empty';
  }

  Widget buildSearchForm(BuildContext context) {
    final searchController = TextEditingController();

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String>(
          future: _fetchUID(),
          builder: (context, UID) =>
              //if snapshot has data, then build the form
              UID.hasData
                  ? Column(
                      children: [
                        TextField(
                          controller: searchController,
                          onChanged: (value) {
                            // Trigger the search using the entered query
                            final query = searchController.text;
                            context
                                .read<SearchBloc>()
                                .searchTravel(query, UID.data!);
                          },
                          decoration: InputDecoration(
                            hintText:
                                'Search for travels (User Name, Travel Name) ',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              onPressed: () {
                                // Trigger the search using the entered query
                                final query = searchController.text;
                                context
                                    .read<SearchBloc>()
                                    .searchTravel(query, UID.data!);
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(child: CircularProgressIndicator()),
        ));
  }

  Widget buildSearchResults() {
    // Implement the UI to display search results
    // Example: return ListView.builder(itemBuilder: (context, index) => ...)
    return Expanded(
      child: ListView.builder(
        itemCount: context.read<SearchBloc>().travelsByTravelNameSearch.length,
        itemBuilder: (context, index) {
          Travel travel =
              context.read<SearchBloc>().travelsByTravelNameSearch[index];
          return ListTile(
            title: Text(travel.name),
            subtitle: Text(travel.activitiesPreferences.toString()),
            onTap: () {
              Navigator.pushNamed(context, '/travelDetail', arguments: travel);
            },
          );
        },
      ),
    );
  }
}
