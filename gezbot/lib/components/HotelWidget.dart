import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:gezbot/models/hotel.model.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HotelWidget extends StatelessWidget {
  final Hotel hotel;

  const HotelWidget({Key? key, required this.hotel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ExpansionTile(
        collapsedIconColor: Colors.amber,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: AutoSizeText(
                hotel.name,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 14,
                ),
                Text(
                  hotel.rating.toString(),
                  style: const TextStyle(
                    overflow: TextOverflow.clip,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Price: ${hotel.price.toString()}₺',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${hotel.reviewCount.toString()} reviews',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SelectableText(
                () {
                  if (hotel.address.isEmpty) {
                    return "*No address found \nCoordinates : ${hotel.coordinates.toString()}";
                  } else {
                    return hotel.address;
                  }
                }(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(hotel.amenities.length, (index) {
                    return Chip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.string(
                            "<svg  width=\"25\" height=\"25\"   fill=\"none\"><path d=\"${hotel.icons[index]}\" fill=\"black\" /></svg>",
                            width: 16,
                            height: 16,
                          ),
                          Text(
                            hotel.amenities[index],
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () {
                    launchUrlString(hotel.link);
                  },
                  child: const Text('See More Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
