import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  /*
  amenities: [
                          [
                            "Free breakfast",
                            "Free Wi-Fi",
                            "Free parking",
                            "Hot tub",
                            "Air conditioning",
                            "Fitness center",
                            "Spa",
                            "Bar"
                          ],
                          [
                            "M4 19h16v2H4zM20 3H4v10c0 2.21 1.79 4 4 4h6c2.21 0 4-1.79 4-4v-3h2a2 2 0 0 0 2-2V5c0-1.11-.89-2-2-2zm-4 10c0 1.1-.9 2-2 2H8c-1.1 0-2-.9-2-2V5h10v8zm4-5h-2V5h2v3z",
                            "M1 9l2 2c4.97-4.97 13.03-4.97 18 0l2-2C16.93 2.93 7.08 2.93 1 9zm8 8l3 3 3-3a4.237 4.237 0 0 0-6 0zm-4-4l2 2a7.074 7.074 0 0 1 10 0l2-2C15.14 9.14 8.87 9.14 5 13z",
                            "M5.5 18h1c.28 0 .5-.22.5-.5v-1h10v1c0 .28.22.5.5.5h1c.28 0 .5-.22.5-.5v-6l-1.62-4.71c-.15-.46-.59-.79-1.1-.79H7.72c-.51 0-.94.33-1.1.79L5 11.5v6c0 .28.22.5.5.5zm1-6.25h11V15h-11v-3.25zM7.95 7.5h8.1l1 2.75H6.95l1-2.75zm8.05 6c0 .55-.45 1-1 1s-1-.45-1-1 .45-1 1-1 1 .45 1 1zm-6 0c0 .55-.45 1-1 1s-1-.45-1-1 .45-1 1-1 1 .45 1 1zM20 2H4c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 18H4V4h16v16z",
                            "M11.15 12c-.31-.22-.59-.46-.82-.72l-1.4-1.55c-.19-.21-.43-.38-.69-.5-.29-.14-.62-.23-.96-.23h-.03C6.01 9 5 10.01 5 11.25V12H2v8c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2v-8H11.15zM7 20H5v-6h2v6zm4 0H9v-6h2v6zm4 0h-2v-6h2v6zm4 0h-2v-6h2v6zM17.42 7.21c.57.62.82 1.41.67 2.2l-.11.59h1.91l.06-.43c.21-1.36-.27-2.71-1.3-3.71l-.07-.07c-.57-.62-.82-1.41-.67-2.2L18 3h-1.89l-.06.43c-.2 1.36.27 2.71 1.3 3.72l.07.06zm-4 0c.57.62.82 1.41.67 2.2l-.11.59h1.91l.06-.43c.21-1.36-.27-2.71-1.3-3.71l-.07-.07c-.57-.62-.82-1.41-.67-2.2L14 3h-1.89l-.06.43c-.2 1.36.27 2.71 1.3 3.72l.07.06z",
                            "M22 11h-4.17l3.24-3.24-1.41-1.42L15 11h-2V9l4.66-4.66-1.42-1.41L13 6.17V2h-2v4.17L7.76 2.93 6.34 4.34 11 9v2H9L4.34 6.34 2.93 7.76 6.17 11H2v2h4.17l-3.24 3.24 1.41 1.42L9 13h2v2l-4.66 4.66 1.42 1.41L11 17.83V22h2v-4.17l3.24 3.24 1.42-1.41L13 15v-2h2l4.66 4.66 1.41-1.42L17.83 13H22v-2z",
                            "M20.57 14.86L22 13.43 20.57 12 17 15.57 8.43 7 12 3.43 10.57 2 9.14 3.43 7.71 2 5.57 4.14 4.14 2.71 2.71 4.14l1.43 1.43L2 7.71l1.43 1.43L2 10.57 3.43 12 7 8.43 15.57 17 12 20.57 13.43 22l1.43-1.43L16.29 22l2.14-2.14 1.43 1.43 1.43-1.43-1.43-1.43L22 16.29l-1.43-1.43z",
                            "M11.48 14c.18.22.36.46.52.7.17-.24.34-.47.52-.7.7-.85 1.53-1.59 2.46-2.19C14.87 9.33 13.89 6.89 12 5c-1.89 1.89-2.87 4.33-2.98 6.81.92.6 1.75 1.34 2.46 2.19zM12 8.31c.43.79.72 1.65.87 2.55-.3.24-.59.5-.87.76-.28-.27-.57-.52-.87-.76.15-.89.44-1.76.87-2.55zM12 20a9 9 0 0 0 9-9 9 9 0 0 0-9 9zm2.44-2.44c.71-1.9 2.22-3.42 4.12-4.12a7.04 7.04 0 0 1-4.12 4.12zM3 11a9 9 0 0 0 9 9 9 9 0 0 0-9-9zm2.44 2.44c1.9.71 3.42 2.22 4.12 4.12a7.04 7.04 0 0 1-4.12-4.12z",
                            "M21 3H3v2l8 9v5H6v2h12v-2h-5v-5l8-9V3zM7.43 7L5.66 5h12.69l-1.78 2H7.43z"
                          ]
                        ],
 */

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
                  // Handle See More Details button tap
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
