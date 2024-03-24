import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HotelWidget extends StatelessWidget {
  final String hotelName;
  final int startingPrice;
  final List<List<String>> amenities;
  final double hotelRate;
  final int hotelReviewCount;
  final String hrefAttribute;

  const HotelWidget({
    super.key,
    required this.hotelName,
    required this.startingPrice,
    required this.amenities,
    required this.hotelRate,
    required this.hotelReviewCount,
    required this.hrefAttribute,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          // Handle onTap event
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                hotelName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Starting price: \$${startingPrice.toString()}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(amenities[0].length, (index) {
                  return Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.string(
                          "<svg  width=\"30\" height=\"30\"   fill=\"none\"><path d=\"${amenities[1][index]}\" fill=\"black\" /></svg>",
                        ),
                        Text(amenities[0][index]),
                      ],
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    hotelRate.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${hotelReviewCount.toString()} reviews)',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton(
                onPressed: () {
                  launchUrlString(hrefAttribute);
                },
                child: const Text('See More Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
