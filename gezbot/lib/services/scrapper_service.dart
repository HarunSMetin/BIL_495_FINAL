import 'dart:convert';
import 'package:http/http.dart' as http;

class ScrapperService {
  final String URL = 'http://127.0.0.1:8000';

  Future<List<dynamic>> getFlights(
      String from, String to, String departureDate, String returnDate) async {
    final response = await http.post(
      Uri.parse("$URL/flights"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'from_': from,
        'to': to,
        'departure_date': departureDate,
        'return_date': returnDate,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load flights');
    }
  }
}
