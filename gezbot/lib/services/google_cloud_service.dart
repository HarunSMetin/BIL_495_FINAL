import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GoogleCloudService {
  late String _apiKey;

  GoogleCloudService() {
    _apiKey = dotenv.env['API_KEY'] ?? '';
  }

  Future<dynamic> _getFunction(String url, Map<String, String> params,
      {bool limit = false}) async {
    List<dynamic> places = [];
    do {
      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return 'Error making API request! Response Code : ${response.statusCode}';
      }

      final data = json.decode(response.body);
      if (data["status"] != "OK") {
        return 'Error making API request! Status : ${data["status"]}';
      }

      places.addAll(data["results"] ?? []);

      if (limit || data["next_page_token"] == null) {
        break;
      }
      params["pagetoken"] = data["next_page_token"];
      await Future.delayed(const Duration(seconds: 2));
    } while (true);

    return places;
  }

  Future<dynamic> _postFunction(
      String url, Map<String, dynamic> jsonBody) async {
    final response = await http.post(Uri.parse(url),
        body: json.encode(jsonBody),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode != 200) {
      return 'Error making API request! Response Code : ${response.statusCode}';
    }

    final data = json.decode(response.body);
    if (data["status"] != "OK") {
      return 'Error making API request! Status : ${data["status"]}';
    }

    return data;
  }

  Future<Map<String, String>> coordinatesToAddress(double lat, double lng,
      {String language = "en", bool detailed = false}) async {
    String url = "https://maps.googleapis.com/maps/api/geocode/json";
    Map<String, String> params = {
      "latlng": "$lat,$lng",
      "key": _apiKey,
      "language": language,
    };

    final result = await _getFunction(url, params, limit: true);
    if (result is String) {
      return {"error": result};
    }

    // Default values for the address components
    String city = "", country = "", street = "", postalCode = "", state = "";
    for (var component in result[0]['address_components']) {
      if (component['types'].contains('locality')) {
        city = component['long_name'];
      } else if (component['types'].contains('country')) {
        country = component['long_name'];
      } else if (component['types'].contains('route')) {
        street = component['long_name'];
      } else if (component['types'].contains('postal_code')) {
        postalCode = component['long_name'];
      } else if (component['types'].contains('administrative_area_level_1')) {
        state = component['long_name'];
      }
    }

    Map<String, String> addressDetails = {
      "city": city,
      "country": country,
      "street": street,
      "postalCode": postalCode,
      "state": state
    };

    if (!detailed) {
      // If not detailed, remove additional information except city and country.
      addressDetails.remove("street");
      addressDetails.remove("postalCode");
      addressDetails.remove("state");
    }

    return addressDetails;
  }

  Future<dynamic> fetchPlacesNearby(String location, List<String> types,
      {int radius = 50000, String language = "en"}) async {
    String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json";
    Map<String, String> params = {
      "location": location,
      "radius": radius.toString(),
      "key": _apiKey,
      "language": language,
      "type": types.join("|"),
      "businessStatus": "OPERATIONAL",
    };
    return await _getFunction(url, params);
  }

  Future<dynamic> fetchPlacesQuery(String queryString,
      {List<String> types = const [], bool limit = false}) async {
    String url = "https://maps.googleapis.com/maps/api/place/textsearch/json";
    Map<String, String> params = {
      "query": queryString,
      "key": _apiKey,
    };
    if (types.isNotEmpty) {
      params["type"] = types.join("|");
    }
    return await _getFunction(url, params, limit: limit);
  }

  Future<List<dynamic>> fetchPlacesAllMethods(
      {String queryString = "",
      String location = "",
      List<String> types = const [],
      int radius = 15000,
      String language = "en"}) async {
    List<dynamic> places = [];
    Set<String> uniquePlaceIds = {};

    if (queryString.isNotEmpty) {
      var queryPlaces =
          await fetchPlacesQuery(queryString, types: types, limit: true);
      if (queryPlaces is String) {
        // Error handling
        return [queryPlaces];
      }
      for (var place in queryPlaces) {
        if (!uniquePlaceIds.contains(place["place_id"])) {
          places.add(place);
          uniquePlaceIds.add(place["place_id"]);
        }
      }
    }

    if (location.isNotEmpty && types.isNotEmpty) {
      var nearbyPlaces = await fetchPlacesNearby(location, types,
          radius: radius, language: language);
      if (nearbyPlaces is String) {
        // Error handling
        return [nearbyPlaces];
      }
      for (var place in nearbyPlaces) {
        if (!uniquePlaceIds.contains(place["place_id"])) {
          places.add(place);
          uniquePlaceIds.add(place["place_id"]);
        }
      }
    }

    return places;
  }

  Future<dynamic> fetchPlaceDetails(String placeId) async {
    String url = "https://maps.googleapis.com/maps/api/place/details/json";
    Map<String, String> params = {
      "place_id": placeId,
      "key": _apiKey,
      "region": "TR"
    };
    return await _getFunction(url, params, limit: true);
  }

  Future<dynamic> fetchCarRoute(String origin, String destination,
      {String mode = "driving",
      bool alternatives = true,
      String? avoid,
      String language = "en",
      String units = "metric",
      String? departureTime,
      String? arrivalTime,
      String? transitMode,
      String? transitRoutingPreference,
      String? trafficModel}) async {
    String url = "https://maps.googleapis.com/maps/api/directions/json";
    Map<String, String> params = {
      "origin": origin,
      "destination": destination,
      "key": _apiKey,
      "mode": mode,
      "alternatives": alternatives.toString(),
      "language": language,
      "units": units,
    };

    if (avoid != null) params["avoid"] = avoid;
    if (departureTime != null) params["departure_time"] = departureTime;
    if (arrivalTime != null) params["arrival_time"] = arrivalTime;
    if (transitMode != null) params["transit_mode"] = transitMode;
    if (transitRoutingPreference != null)
      params["transit_routing_preference"] = transitRoutingPreference;
    if (trafficModel != null) params["traffic_model"] = trafficModel;

    return await _getFunction(url, params);
  }
}
