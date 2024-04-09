import 'dart:convert';
import 'package:gezbot/models/travel.model.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class AICreatedTravel {
  final String travelId;

  final String additionalNotes;
  //fill inside
  AICreatedTravel({
    required this.travelId,
    required this.additionalNotes,
  });
}

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
    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      var jsonResponse = jsonDecode(responseBody);
      // Assuming 'content' contains the JSON data you want to return
      return jsonDecode(jsonResponse['choices'][0]['message']['content']);
    } else {
      developer.log('Failed to load recommendations');
      throw Exception('Failed to load recommendations');
    }
  }

  Future<Map<String, dynamic>> getHotelRecommendations(Travel travel) async {
    String prompt = _createHotelPrompt(travel);
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
    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      var jsonResponse = jsonDecode(responseBody);
      // Assuming 'content' contains the JSON data you want to return
      return jsonDecode(jsonResponse['choices'][0]['message']['content']);
    } else {
      developer.log('Failed to load recommendations');
      throw Exception('Failed to load recommendations');
    }
  }

  String _createPrompt(Travel travel) {
    return "Travel details: Departure: ${travel.departureDate}, Return: ${travel.returnDate},Departure From: Ankara, Destination: ${travel.desiredDestination}, Budget: ${travel.estimatedBudget}. Provide suggestions for flights, accommodations, and activities.";
  }

  var domains =
      '"stars": [3,4,5],"hotel_types": ["spa","hostel","boutique","bed_and_breakfast","beach","motel","apartment","inn","resort","other"],"hotel_options": ["free_wifi","free_breakfast","restaurant","bar","kid_friendly","pet_friendly","free_parking","parking","ev_charger","room_service","fitness_center","spa","pool","indoor_pool","outdoor_pool","air_conditioned","wheelchair_accessible","beach_access","all_inclusive_available"]';
  String out =
      '{"place": "#destination","checkin": "yyyy-mm-dd","checkout": "yyyy-mm-dd","stars": [4, 5],"hotel_types": ["hostel", "boutique", "bed_and_breakfast"],"hotel_options": ["free_wifi", "room_service", "pool", "air_conditioned"],"adults": 1,"children": 0}';
  String _createHotelPrompt(Travel travel) {
    return "You are backend of AI TRAVEL PLANNER, You can return just Json. Travel details: ${travel.toString()} . 02_DepartureDate = checkin . 03_ReturnDate = checkout. You should select best and most relevant Tags for this travel, based on given informations. Here is list for domains you should select only given domains : $domains You will Provide JUST structure FOR EXAMPLE :  $out  . Provide ONE suggestion in JSON FORMAT. You must return JUST json.";
  }

  AICreatedTravel _parseAIResponse(String response, String travelId) {
    return AICreatedTravel(
      travelId: travelId,
      additionalNotes: response,
    );
  }

  String createChatBotPrompt(String message, Travel travel) {
    String prompt =
        "You are traveller app assistant chat bot. You can only answer to the questions. You can provide information about the travel, provide suggestions for flights, accommodations, and activities. You can also provide general information about the destination.YOU MUST ANSWER JUST ABOUT TRAVEL RELATED QUESTIONS. Here is travel structure :  ${travel.toString()} . Provide suggestions for flights, accommodations, and activities. Here is the given question or chat to response :  $message";
    return prompt;
  }

  Future<String> getChatBotResponse(String message, Travel travel) async {
    String prompt = createChatBotPrompt(message, travel);
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
    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      var jsonResponse = jsonDecode(responseBody);
      // Assuming 'content' contains the JSON data you want to return
      return jsonResponse['choices'][0]['message']['content'];
    } else {
      developer.log('Failed to load chatbot response');
      return '';
    }
  }
}
