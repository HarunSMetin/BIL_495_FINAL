import 'package:flutter/material.dart';
import 'package:gezbot/models/place.model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gezbot/components/DetailedPlaceWidget.dart';

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
  final Place place;

  const PlaceWidget({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Image.network(place.icon ?? '', width: 50, height: 50),
          title: Text(place.name ?? ''),
          subtitle: Text(
              'Rating: ${place.rating} (${place.userRatingsTotal} reviews)'),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailedPlaceWidget(place: place),
              ),
            );
          },
        ),
      ],
    );
  }
}
