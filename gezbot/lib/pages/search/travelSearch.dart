import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/pages/search/helperSearchFunc.dart';
import 'package:gezbot/pages/travel/travel_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelView extends StatefulWidget {
  const TravelView({super.key});

  @override
  State<TravelView> createState() => _TravelViewState();
}

class _TravelViewState extends State<TravelView> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          buildSearchForm(context),
          SearchView(),
          const Divider(height: 10.0, color: Color.fromARGB(120, 97, 94, 94)),
          const Text(
            'Travels by User Name',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          searchViewForUsernameSearchedTravel(),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget SearchView() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state == SearchState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state == SearchState.loaded) {
          // Render the list of users
          return buildSearchResults();
        } else if (state == SearchState.error) {
          return const Center(
            child: Text('Error fetching Travels. Please try again.'),
          );
        } else {
          return const Expanded(
            child: Center(
              child: Text('Please enter a query to begin'),
            ),
          );
        }
      },
    );
  }

  Widget searchViewForUsernameSearchedTravel() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state == SearchState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state == SearchState.loaded) {
          // Render the list of users
          return buildSearchByUserName();
        } else if (state == SearchState.error) {
          return const Center(
            child: Text(
                'Error fetching Travels Based UserName. Please try again.'),
          );
        } else {
          return const Expanded(
            child: Center(
              child: Text('User Name based travel search results.'),
            ),
          );
        }
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
          builder: (context, uID) =>
              //if snapshot has data, then build the form
              uID.hasData
                  ? Column(
                      children: [
                        TextField(
                          controller: searchController,
                          onChanged: (value) {
                            // Trigger the search using the entered query
                            final query = searchController.text;
                            context
                                .read<SearchBloc>()
                                .searchTravel(query, uID.data!);
                          },
                          decoration: InputDecoration(
                            hintText:
                                'Search for travels (User Name, Travel Name) ',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                // Trigger the search using the entered query
                                final query = searchController.text;
                                context
                                    .read<SearchBloc>()
                                    .searchTravel(query, uID.data!);
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
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

  Widget buildSearchByUserName() {
    return Expanded(
      child: ListView.builder(
        itemCount: context.read<SearchBloc>().travelsByUserNameSearch.length,
        itemBuilder: (context, index) {
          Travel travel =
              context.read<SearchBloc>().travelsByUserNameSearch[index];
          return ListTile(
            title: Text(travel.name),
            subtitle: Text(travel.activitiesPreferences.toString()),
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
