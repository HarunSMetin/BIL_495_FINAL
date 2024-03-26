class Hotel {
  final String id;
  final String name;
  final String address;
  final List<double> coordinates;
  final int price;
  final List<String> amenities;
  final List<String> icons;
  final double rating;
  final int reviewCount;
  final String link;

  Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.coordinates,
    required this.price,
    required this.amenities,
    required this.icons,
    required this.rating,
    required this.reviewCount,
    required this.link,
  });

  factory Hotel.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return Hotel(
        id: '',
        name: '',
        address: '',
        coordinates: [0.0, 0.0],
        price: 0,
        amenities: [''],
        icons: [''],
        rating: 0.0,
        reviewCount: 0,
        link: '',
      );
    }
    return Hotel(
      id: (map['hotel_id'] ?? '').toString(),
      name: (map['hotel_name'] ?? '').toString(),
      address: (map['hotel_address'] ?? '').toString(),
      coordinates: List<double>.from(map['coordinates'] ?? [0.0, 0.0]),
      price: map['starting_price'] ?? 0,
      amenities: List<String>.from(map['amenities'] ?? ['']),
      icons: List<String>.from(map['icons'] ?? ['']),
      rating: map['hotel_rate'] ?? 0.0,
      reviewCount: map['hotel_review_count'] ?? 0,
      link: (map['href_attribute'] ??
              'https://www.google.com/travel/hotels?hl=en&gl=en&un=1&ap=MABoACgAQABSAFgAYgBhAGwAaQBlAHMAKAAw')
          .toString(),
    );
  }
  @override
  String toString() {
    return 'Hotel(name: $name, address: $address, coordinates: $coordinates, price: $price, amenities: $amenities, icons: $icons, rating: $rating, reviewCount: $reviewCount, link: $link)';
  }
}
