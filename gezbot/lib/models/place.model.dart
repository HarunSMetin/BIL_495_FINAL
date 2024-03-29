class Place {
  final String? id;
  final List<String>? types;
  final String? businessStatus;
  final double? rating;
  final String? icon;
  final String? iconBackgroundColor;
  final List<Photo>? photos;
  final String? reference;
  final int? userRatingsTotal;
  final String? scope;
  final String? name;
  final String? iconMaskBaseUri;
  final Geometry? geometry;
  final String? vicinity;
  final PlusCode? plusCode;

  Place({
    this.id,
    this.types,
    this.businessStatus,
    this.rating,
    this.icon,
    this.iconBackgroundColor,
    this.photos,
    this.reference,
    this.userRatingsTotal,
    this.scope,
    this.name,
    this.iconMaskBaseUri,
    this.geometry,
    this.vicinity,
    this.plusCode,
  });

  factory Place.fromMap(Map<String, dynamic>? json) {
    return Place(
      id: json?['id'],
      types: json?['types'] != null ? List<String>.from(json?['types']) : null,
      businessStatus: json?['business_status'],
      rating: json?['rating']?.toDouble(),
      icon: json?['icon'],
      iconBackgroundColor: json?['icon_background_color'],
      photos: json?['photos'] != null
          ? List<Photo>.from(json?['photos'].map((x) => Photo.fromMap(x)))
          : null,
      reference: json?['reference'],
      userRatingsTotal: json?['user_ratings_total'],
      scope: json?['scope'],
      name: json?['name'],
      iconMaskBaseUri: json?['icon_mask_base_uri'],
      geometry: json?['geometry'] != null
          ? Geometry.fromMap(json?['geometry'])
          : null,
      vicinity: json?['vicinity'],
      plusCode: json?['plus_code'] != null
          ? PlusCode.fromMap(json?['plus_code'])
          : null,
    );
  }

  Map<String, dynamic> toMap(Place? place) {
    return {
      'id': place?.id,
      'types': place?.types,
      'business_status': place?.businessStatus,
      'rating': place?.rating,
      'icon': place?.icon,
      'icon_background_color': place?.iconBackgroundColor,
      'photos': place?.photos?.map((x) => x.toMap(x)).toList(),
      'reference': place?.reference,
      'user_ratings_total': place?.userRatingsTotal,
      'scope': place?.scope,
      'name': place?.name,
      'icon_mask_base_uri': place?.iconMaskBaseUri,
      'geometry': place?.geometry?.toMap(place.geometry),
      'vicinity': place?.vicinity,
      'plus_code': place?.plusCode?.toMap(place.plusCode),
    };
  }
}

class Photo {
  final String? photoReference;
  final int? width;
  final int? height;
  final List<String>? htmlAttributions;

  Photo({
    this.photoReference,
    this.width,
    this.height,
    this.htmlAttributions,
  });

  factory Photo.fromMap(Map<String, dynamic>? json) {
    return Photo(
      photoReference: json?['photo_reference'],
      width: json?['width'],
      height: json?['height'],
      htmlAttributions: json?['html_attributions'] != null
          ? List<String>.from(json?['html_attributions'])
          : null,
    );
  }
  Map<String, dynamic> toMap(Photo? photo) {
    return {
      'photo_reference': photo?.photoReference,
      'width': photo?.width,
      'height': photo?.height,
      'html_attributions': photo?.htmlAttributions,
    };
  }
}

class Geometry {
  final Viewport? viewport;
  final Location? location;

  Geometry({this.viewport, this.location});

  factory Geometry.fromMap(Map<String, dynamic>? json) {
    return Geometry(
      viewport: json?['viewport'] != null
          ? Viewport.fromMap(json!['viewport'])
          : null,
      location: json?['location'] != null
          ? Location.fromMap(json?['location'])
          : null,
    );
  }
  Map<String, dynamic> toMap(Geometry? geometry) {
    return {
      'viewport': geometry?.viewport?.toMap(geometry.viewport),
      'location': geometry?.location?.toMap(geometry.location),
    };
  }
}

class Viewport {
  final Location? southwest;
  final Location? northeast;

  Viewport({this.southwest, this.northeast});

  factory Viewport.fromMap(Map<String, dynamic>? json) {
    return Viewport(
      southwest: json?['southwest'] != null
          ? Location.fromMap(json?['southwest'])
          : null,
      northeast: json?['northeast'] != null
          ? Location.fromMap(json?['northeast'])
          : null,
    );
  }
  Map<String, dynamic> toMap(Viewport? viewport) {
    return {
      'southwest': viewport?.southwest?.toMap(viewport.southwest),
      'northeast': viewport?.northeast?.toMap(viewport.northeast),
    };
  }
}

class Location {
  final double? lng;
  final double? lat;

  Location({this.lng, this.lat});

  factory Location.fromMap(Map<String, dynamic>? json) {
    return Location(
      lng: json?['lng']?.toDouble(),
      lat: json?['lat']?.toDouble(),
    );
  }
  Map<String, dynamic> toMap(Location? location) {
    return {
      'lng': location?.lng,
      'lat': location?.lat,
    };
  }
}

class PlusCode {
  final String? compoundCode;

  PlusCode({this.compoundCode});

  factory PlusCode.fromMap(Map<String, dynamic>? json) {
    return PlusCode(
      compoundCode: json?['compound_code'],
    );
  }
  Map<String, dynamic> toMap(PlusCode? plusCode) {
    return {
      'compound_code': plusCode?.compoundCode,
    };
  }
}
