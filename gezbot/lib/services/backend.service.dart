import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:http/http.dart' as http;
import 'package:gezbot/services/gpt_service.dart';

class BackendService {
  late String GPT_API_KEY;
  late String URL;
  final Travel travel;
  BackendService({required this.travel}) {
    GPT_API_KEY = dotenv.env['GPT_API_KEY'] ?? '';
    URL = dotenv.env['BACKEND_URL'] ?? 'http://127.0.0.1:8000';
  }

  Future<bool> findHotels() async {
    Map<String, dynamic> JsonSuggestion =
        await GPTService(apiKey: GPT_API_KEY).getHotelRecommendations(travel);
    if (JsonSuggestion['place'] != null &&
        JsonSuggestion['checkin'] != null &&
        JsonSuggestion['checkout'] != null &&
        JsonSuggestion['stars'] != null &&
        JsonSuggestion['hotel_types'] != null &&
        JsonSuggestion['hotel_options'] != null &&
        JsonSuggestion['adults'] != null &&
        JsonSuggestion['children'] != null) {
      final response = await http.post(Uri.parse("$URL/find_hotels"),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'TravelID': travel.id,
            'place': JsonSuggestion['place'],
            'checkin': JsonSuggestion['checkin'],
            'checkout': JsonSuggestion['checkout'],
            'stars': JsonSuggestion['stars'],
            'hotel_types': JsonSuggestion['hotel_types'],
            'hotel_options': JsonSuggestion['hotel_options'],
            'adults': JsonSuggestion['adults'],
            'children': JsonSuggestion['children']
          }),
          encoding: const Utf8Codec());

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to load hotels');
      }
    } else {
      return false;
    }
  }

  Future<bool> findPlaces() async {
    final response = await http.post(
        Uri.parse("$URL/find_places"), // Update the endpoint here
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'TravelID': travel.id,
        }),
        encoding: const Utf8Codec());

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to load places');
    }
  }
}
