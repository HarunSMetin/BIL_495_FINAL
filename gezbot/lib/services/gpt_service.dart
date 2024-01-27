import 'dart:convert';
import 'package:gezbot/models/ai.travel.model.dart';
import 'package:gezbot/models/travel.model.dart';
import 'package:gezbot/services/database_service.dart';
import 'package:http/http.dart' as http;

class GPTService {
  final String apiKey;
  final String apiUrl;

  GPTService(
      {this.apiKey = 'API_KEY',
      this.apiUrl = 'https://api.openai.com/v1/chat/completions'});

  Future<AICreatedTravel> getTravelRecommendations(Travel travel) async {
    String prompt = _createPrompt(travel);
    final response = await http
        .post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-3.5-turbo-1106',
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
            'temperature': 0.7,
            'max_tokens': 500,
          }),
        )
        .timeout(const Duration(seconds: 60));
    ;
    print(response.body);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      // GPT-3.5 Turbo'nun cevabını işleme
      return _parseAIResponse(jsonResponse, travel.id);
    } else {
      print(response.body);
      throw Exception('Failed to load recommendations');
    }
  }

  String _createPrompt(Travel travel) {
    return "Travel details: Departure: ${travel.departureDate}, Return: ${travel.returnDate},Departure From: Ankara, Destination: ${travel.desiredDestination}, Budget: ${travel.estimatedBudget}. Provide suggestions for flights, accommodations, and activities.";
  }

  AICreatedTravel _parseAIResponse(String response, String travelId) {
    print(response);
    return AICreatedTravel(
      travelId: travelId,
      suggestedFlights: [/* ... */],
      suggestedBuses: [/* ... */],
      suggestedAccommodations: [/* ... */],
      suggestedActivities: [/* ... */],
      additionalNotes:
          response, // veya daha detaylı bir parse işlemi yapılabilir
    );
  }
}
