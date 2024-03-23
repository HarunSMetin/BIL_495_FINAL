import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceSelectorWidget extends StatefulWidget {
  final Function(String) onAnswerChanged;

  const PlaceSelectorWidget({super.key, required this.onAnswerChanged});
  @override
  _PlaceSelectorWidgetState createState() => _PlaceSelectorWidgetState();
}

class _PlaceSelectorWidgetState extends State<PlaceSelectorWidget> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {Marker(markerId: MarkerId("current-location"))};

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Fetch user's location on widget initialization
  }

  Future<LatLng> _getUserLocation() async {
    LatLng currentUserLocation = LatLng(37.42796133580664, -122.085749655962);
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId("selected-location"),
          position: currentUserLocation,
        )
      };
    });
    return currentUserLocation;
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
        )
      };
      widget.onAnswerChanged("${position.latitude},${position.longitude}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<LatLng>(
        future: _getUserLocation(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: snapshot.data!,
                zoom: 14.0,
              ),
              markers: _markers,
              onTap: _onMapTap,
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
