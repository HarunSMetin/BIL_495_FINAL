import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final List<LatLng> pointsToMark;

  const MapWidget({
    super.key,
    this.initialPosition = const LatLng(45.521563, -122.677433),
    this.pointsToMark = const [],
  });

  @override
  // ignore: library_private_types_in_public_api
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController mapController;

  final Set<Polyline> _polylines = <Polyline>{};

  final Set<Marker> _markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    _markers.addAll(widget.pointsToMark.map((point) => Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'Waypoint'),
        )));
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    final String route = await _getRoute(widget.pointsToMark);
    _drawRoute(route);
  }

  Future<String> _getRoute(List<LatLng> waypoints) async {
    final String apiKey = dotenv.env['API_KEY']!;
    final String waypointsString = waypoints
        .map((point) => '${point.latitude},${point.longitude}')
        .join('|');
    final Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${widget.initialPosition.latitude},${widget.initialPosition.longitude}&destination=${widget.initialPosition.latitude},${widget.initialPosition.longitude}&waypoints=optimize:true|$waypointsString&key=$apiKey');

    final http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      String polyline = data['routes'][0]['overview_polyline']['points'];

      return polyline;
    } else {
      throw Exception('Failed to fetch route');
    }
  }

  void _drawRoute(String route) {
    List<LatLng> routePoints = _convertToLatLng(_decodePoly(route));

    // Add polyline for the route
    if (routePoints.isNotEmpty) {
      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        width: 4,
        color: Colors.blue,
      ));
    } else {
      print('Route points are empty or invalid.');
    }

    // Add markers for waypoints
    for (LatLng point in widget.pointsToMark) {
      _markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'Waypoint'),
      ));
    }

    setState(() {});
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = <double>[];
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 0x20);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);
    for (var i = 2; i < lList.length; i++) {
      lList[i] += lList[i - 2];
    }
    return lList;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: 11.0,
      ),
      polylines: _polylines,
      markers: _markers,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
    );
  }
}
