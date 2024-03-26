class Place {
  final String id;
  final List<String> types;
  final String businessStatus;
  final double rating;
  final String icon;
  final String iconBackgroundColor;
  final List<Photo> photos;
  final String reference;
  final int userRatingsTotal;
  final String scope;
  final String name;
  final String iconMaskBaseUri;
  final Geometry geometry;
  final String vicinity;
  final PlusCode plusCode;

  Place({
    required this.id,
    required this.types,
    required this.businessStatus,
    required this.rating,
    required this.icon,
    required this.iconBackgroundColor,
    required this.photos,
    required this.reference,
    required this.userRatingsTotal,
    required this.scope,
    required this.name,
    required this.iconMaskBaseUri,
    required this.geometry,
    required this.vicinity,
    required this.plusCode,
  });

  factory Place.fromMap(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      types: List<String>.from(json['types']),
      businessStatus: json['business_status'],
      rating: json['rating'],
      icon: json['icon'],
      iconBackgroundColor: json['icon_background_color'],
      photos: List<Photo>.from(json['photos'].map((x) => Photo.fromMap(x))),
      reference: json['reference'],
      userRatingsTotal: json['user_ratings_total'],
      scope: json['scope'],
      name: json['name'],
      iconMaskBaseUri: json['icon_mask_base_uri'],
      geometry: Geometry.fromMap(json['geometry']),
      vicinity: json['vicinity'],
      plusCode: PlusCode.fromMap(json['plus_code']),
    );
  }
}

class Photo {
  final String photoReference;
  final int width;
  final int height;
  final List<String> htmlAttributions;

  Photo({
    required this.photoReference,
    required this.width,
    required this.height,
    required this.htmlAttributions,
  });

  factory Photo.fromMap(Map<String, dynamic> json) {
    return Photo(
      photoReference: json['photo_reference'],
      width: json['width'],
      height: json['height'],
      htmlAttributions: List<String>.from(json['html_attributions']),
    );
  }
}

class Geometry {
  final Viewport viewport;
  final Location location;

  Geometry({required this.viewport, required this.location});

  factory Geometry.fromMap(Map<String, dynamic> json) {
    return Geometry(
      viewport: Viewport.fromMap(json['viewport']),
      location: Location.fromMap(json['location']),
    );
  }
}

class Viewport {
  final Location southwest;
  final Location northeast;

  Viewport({required this.southwest, required this.northeast});

  factory Viewport.fromMap(Map<String, dynamic> json) {
    return Viewport(
      southwest: Location.fromMap(json['southwest']),
      northeast: Location.fromMap(json['northeast']),
    );
  }
}

class Location {
  final double lng;
  final double lat;

  Location({required this.lng, required this.lat});

  factory Location.fromMap(Map<String, dynamic> json) {
    return Location(
      lng: json['lng'],
      lat: json['lat'],
    );
  }
}

class PlusCode {
  final String compoundCode;

  PlusCode({required this.compoundCode});

  factory PlusCode.fromMap(Map<String, dynamic> json) {
    return PlusCode(
      compoundCode: json['compound_code'],
    );
  }
}
