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
      users = await databaseService.searchByUserNameAndEmail(query);
      emit(SearchState.loaded);
    } catch (e) {
      emit(SearchState.error);
    }
  }

  void searchTravel(String query, String senderID) async {
    // Add logic to fetch and process user data
    emit(SearchState.loading);

    try {
      travelsByTravelNameSearch =
          await databaseService.searchTravelsByTravelName(query, senderID);
      travelsByUserNameSearch = await databaseService
          .searchTravelsByUserNameAndEmail(query, senderID);
      emit(SearchState.loaded);
    } catch (e) {
      emit(SearchState.error);
    }
  }

  void searchTravelByDestination(String query) async {
    // Add logic to fetch and process user data
    emit(SearchState.loading);

    try {
      travelsByDestinationSearch =
          await databaseService.searchTravelsByDestination(query);
      emit(SearchState.loaded);
    } catch (e) {
      emit(SearchState.error);
    }
  }
}
