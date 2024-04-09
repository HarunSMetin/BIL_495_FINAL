import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceSelectorWidget extends StatefulWidget {
  final Function(String) onAnswerChanged;

  const PlaceSelectorWidget({super.key, required this.onAnswerChanged});

  @override
  // ignore: library_private_types_in_public_api
  _PlaceSelectorWidgetState createState() => _PlaceSelectorWidgetState();
}

class _PlaceSelectorWidgetState extends State<PlaceSelectorWidget> {
  late GoogleMapController mapController;
  final LatLng _initialLocation =
      const LatLng(39.9248866, 32.8345037); // Default or fetched user location
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Initialize markers
    _markers.add(
      Marker(
        markerId: const MarkerId("initial-location"),
        position: _initialLocation,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId("${position.latitude},${position.longitude}"),
          position: position,
        ),
      };
      widget.onAnswerChanged("${position.latitude},${position.longitude}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialLocation,
          zoom: 14.0,
        ),
        markers: _markers,
        onTap: _onMapTap,
      ),
    );
  }
}
