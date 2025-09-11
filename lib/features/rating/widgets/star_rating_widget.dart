import 'package:flutter/material.dart';

/// Star rating widget for displaying and selecting ratings
class StarRatingWidget extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onRatingChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool allowHalfRating;
  final bool readOnly;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.size = 24.0,
    this.activeColor = Colors.orange,
    this.inactiveColor = Colors.grey,
    this.allowHalfRating = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: readOnly ? null : () {
            if (onRatingChanged != null) {
              onRatingChanged!(index + 1);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: index < rating ? activeColor : inactiveColor,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}

/// Star rating display widget (read-only)
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool showHalfStars;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 16.0,
    this.activeColor = Colors.orange,
    this.inactiveColor = Colors.grey,
    this.showHalfStars = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starRating = rating - index;
        
        if (showHalfStars && starRating > 0 && starRating < 1) {
          // Half star
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Stack(
              children: [
                Icon(
                  Icons.star_border,
                  color: inactiveColor,
                  size: size,
                ),
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: starRating,
                    child: Icon(
                      Icons.star,
                      color: activeColor,
                      size: size,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (starRating >= 1) {
          // Full star
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              Icons.star,
              color: activeColor,
              size: size,
            ),
          );
        } else {
          // Empty star
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              Icons.star_border,
              color: inactiveColor,
              size: size,
            ),
          );
        }
      }),
    );
  }
}

/// Rating summary widget
class RatingSummaryWidget extends StatelessWidget {
  final double averageRating;
  final int totalRatings;
  final List<RatingDistribution>? ratingDistribution;

  const RatingSummaryWidget({
    super.key,
    required this.averageRating,
    required this.totalRatings,
    this.ratingDistribution,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Average rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[600],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StarRatingDisplay(
                    rating: averageRating,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on $totalRatings rating${totalRatings != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Rating distribution
          if (ratingDistribution != null && ratingDistribution!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...ratingDistribution!.map((distribution) => 
              _buildRatingBar(context, distribution)
            ).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingBar(BuildContext context, RatingDistribution distribution) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Star count
          SizedBox(
            width: 60,
            child: Row(
              children: [
                Text(
                  '${distribution.rating}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.star,
                  size: 12,
                  color: Colors.orange[600],
                ),
              ],
            ),
          ),
          
          // Progress bar
          Expanded(
            child: Container(
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: distribution.percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.orange[600],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          
          // Percentage
          SizedBox(
            width: 40,
            child: Text(
              '${distribution.percentage.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rating card widget
class RatingCard extends StatelessWidget {
  final RatingModel rating;
  final VoidCallback? onTap;
  final bool showJobTitle;

  const RatingCard({
    super.key,
    required this.rating,
    this.onTap,
    this.showJobTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Customer image
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: rating.customerImageUrl != null
                        ? NetworkImage(rating.customerImageUrl!)
                        : null,
                    child: rating.customerImageUrl == null
                        ? const Icon(Icons.person, size: 20)
                        : null,
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Customer name and rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rating.customerName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        StarRatingDisplay(
                          rating: rating.rating.toDouble(),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                  
                  // Time ago
                  Text(
                    rating.timeAgo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              // Job title
              if (showJobTitle) ...[
                const SizedBox(height: 8),
                Text(
                  'Job: ${rating.jobTitle}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
              
              // Review text
              if (rating.hasReview) ...[
                const SizedBox(height: 12),
                Text(
                  rating.review!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
