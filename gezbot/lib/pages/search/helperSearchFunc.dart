import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/models/user.model.dart';
import 'package:gezbot/services/database_service.dart';

// Define the state
enum SearchState { initial, loading, loaded, error }

class SearchBloc extends Cubit<SearchState> {
  DatabaseService databaseService = DatabaseService();
  SearchBloc() : super(SearchState.initial);
  List<UserModel> users = [];
  List<Travel> travelsByTravelNameSearch = [];
  List<Travel> travelsByUserNameSearch = [];
  List<Travel> travelsByDestinationSearch = [];
  // Add methods for fetching and processing user data
  // You can use API calls, databases, or any other data source

  void searchUsers(String query) async {
    // Add logic to fetch and process user data
    emit(SearchState.loading);

    try {
      users = await databaseService.ByUserNameAndEmail(query);
      emit(SearchState.loaded);
    } catch (e) {
      emit(SearchState.error);
    }
  }

  void searchTravel(String query) async {
    // Add logic to fetch and process user data
    emit(SearchState.loading);

    try {
      travelsByTravelNameSearch =
          await databaseService.SearchTravelsByTravelName(query);
      travelsByUserNameSearch =
          await databaseService.SearchTravelsByUserNameAndEmail(query);
      travelsByDestinationSearch =
          await databaseService.SearchTravelsByDestination(query);
      emit(SearchState.loaded);
    } catch (e) {
      emit(SearchState.error);
    }
  }
}
