import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceDetails {
  final String name;
  final double rating;
  final int userRatingsTotal;
  final String icon;
  final LatLng location;

  PlaceDetails({
    required this.name,
    required this.rating,
    required this.userRatingsTotal,
    required this.icon,
    required this.location,
  });
}

class PlaceWidget extends StatelessWidget {
  final PlaceDetails place;

  const PlaceWidget({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: place.location,
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('place_marker'),
                position: place.location,
                infoWindow: InfoWindow(
                  title: place.name,
                  snippet:
                      'Rating: ${place.rating} (${place.userRatingsTotal} reviews)',
                ),
              ),
            },
          ),
        ),
        ListTile(
          leading: Image.network(place.icon, width: 50, height: 50),
          title: Text(place.name),
          subtitle: Text(
              'Rating: ${place.rating} (${place.userRatingsTotal} reviews)'),
          onTap: () async {
            // Assuming 'photoReference' is the URL you have for the place's photo.
          },
        ),
      ],
    );
  }
}
