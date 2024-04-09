import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/pages/search/helperSearchFunc.dart';
import 'package:gezbot/pages/travel/travel_info.dart';

class DestinationView extends StatefulWidget {
  const DestinationView({super.key});

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
          return const Center(child: CircularProgressIndicator());
        } else if (state == SearchState.loaded) {
          return buildSearchResults();
        } else if (state == SearchState.error) {
          return const Center(
              child: Text('Error fetching destinations. Please try again.'));
        } else {
          return const Text('Please enter a query to begin');
        }
      },
    );
  }

  Widget buildSearchForm(BuildContext context) {
    final searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        onChanged: (value) =>
            context.read<SearchBloc>().searchTravelByDestination(value),
        decoration: InputDecoration(
          hintText: 'Search for destinations',
          filled: true,
          fillColor: const Color.fromARGB(222, 222, 222, 222),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context
                .read<SearchBloc>()
                .searchTravelByDestination(searchController.text),
          ),
        ),
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
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(travel.name,
                  style: TextStyle(color: Colors.blueGrey.shade800)),
              subtitle: Text(travel.desiredDestination,
                  style: TextStyle(color: Colors.blueGrey.shade600)),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TravelInformation(travel: travel))),
            ),
          );
        },
      ),
    );
  }
}
