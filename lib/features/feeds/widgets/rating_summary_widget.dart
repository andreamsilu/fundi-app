import 'package:flutter/material.dart';
import 'package:fundi/features/rating/models/rating_model.dart';

/// Widget to display rating summary with star distribution
class RatingSummaryWidget extends StatelessWidget {
  final double averageRating;
  final int totalRatings;
  final FundiRatingSummary ratingSummary;

  const RatingSummaryWidget({
    Key? key,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingSummary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average Rating Display
        Row(
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < averageRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
                Text(
                  '$totalRatings review${totalRatings != 1 ? 's' : ''}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Star Distribution
        if (totalRatings > 0) ...[
          const Text(
            'Rating Distribution:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...List.generate(5, (index) {
            final starCount = 5 - index;
            final count = _getStarCount(starCount);
            final percentage = totalRatings > 0
                ? (count / totalRatings) * 100
                : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    '$starCount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.amber.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  int _getStarCount(int starCount) {
    switch (starCount) {
      case 5:
        return ratingSummary.fiveStarCount;
      case 4:
        return ratingSummary.fourStarCount;
      case 3:
        return ratingSummary.threeStarCount;
      case 2:
        return ratingSummary.twoStarCount;
      case 1:
        return ratingSummary.oneStarCount;
      default:
        return 0;
    }
  }
}
