import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/pages/profile/profile_page.dart';
import 'package:gezbot/pages/search/helperSearchFunc.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildSearchForm(context),
        searchView(),
      ],
    );
  }

  Widget searchView() {
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
            child: Text('Error fetching users. Please try again.'),
          );
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
        onChanged: (value) => context.read<SearchBloc>().searchUsers(value),
        decoration: InputDecoration(
          hintText: 'Search for users',
          filled: true,
          fillColor: const Color.fromARGB(222, 222, 222, 222),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () =>
                context.read<SearchBloc>().searchUsers(searchController.text),
          ),
        ),
      ),
    );
  }

  Widget buildSearchResults() {
    // Implement the UI to display search results
    // Example: return ListView.builder(itemBuilder: (context, index) => ...)
    return Expanded(
      child: ListView.builder(
        itemCount: context.read<SearchBloc>().users.length,
        itemBuilder: (context, index) {
          UserModel user = context.read<SearchBloc>().users[index];
          return ListTile(
            title: Text(user.userName),
            subtitle: Text(user.email),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userId: user.id,
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
