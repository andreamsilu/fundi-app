/// Rating model representing ratings and reviews
/// This model follows the API structure exactly
class RatingModel {
  final String id;
  final String fundiId;
  final String customerId;
  final String jobId;
  final int rating;
  final String? review;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional fields for UI/UX (not in API but needed for mobile)
  final String? fundiName;
  final String? fundiImageUrl;
  final String? customerName;
  final String? customerImageUrl;
  final String? jobTitle;
  final Map<String, dynamic>? metadata;

  const RatingModel({
    required this.id,
    required this.fundiId,
    required this.customerId,
    required this.jobId,
    required this.rating,
    this.review,
    this.createdAt,
    this.updatedAt,
    this.fundiName,
    this.fundiImageUrl,
    this.customerName,
    this.customerImageUrl,
    this.jobTitle,
    this.metadata,
  });

  /// Get star rating display
  String get starRating {
    return '★' * rating + '☆' * (5 - rating);
  }

  /// Check if rating has review
  bool get hasReview => review != null && review!.isNotEmpty;

  /// Get formatted rating date
  String get formattedDate {
    if (createdAt == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Create RatingModel from JSON (follows API structure)
  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id']
          .toString(), // Convert to String to handle both int and String
      fundiId: json['fundi_id']
          .toString(), // Convert to String to handle both int and String
      customerId: json['customer_id']
          .toString(), // Convert to String to handle both int and String
      jobId: json['job_id']
          .toString(), // Convert to String to handle both int and String
      rating: json['rating'] as int,
      review: json['review'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      fundiName: json['fundi_name'] as String?, // Additional field for mobile
      fundiImageUrl:
          json['fundi_image_url'] as String?, // Additional field for mobile
      customerName:
          json['customer_name'] as String?, // Additional field for mobile
      customerImageUrl:
          json['customer_image_url'] as String?, // Additional field for mobile
      jobTitle: json['job_title'] as String?, // Additional field for mobile
      metadata:
          json['metadata']
              as Map<String, dynamic>?, // Additional field for mobile
    );
  }

  /// Convert RatingModel to JSON (follows API structure exactly)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fundi_id': fundiId,
      'customer_id': customerId,
      'job_id': jobId,
      'rating': rating,
      'review': review,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  RatingModel copyWith({
    String? id,
    String? fundiId,
    String? customerId,
    String? jobId,
    int? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fundiName,
    String? fundiImageUrl,
    String? customerName,
    String? customerImageUrl,
    String? jobTitle,
    Map<String, dynamic>? metadata,
  }) {
    return RatingModel(
      id: id ?? this.id,
      fundiId: fundiId ?? this.fundiId,
      customerId: customerId ?? this.customerId,
      jobId: jobId ?? this.jobId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fundiName: fundiName ?? this.fundiName,
      fundiImageUrl: fundiImageUrl ?? this.fundiImageUrl,
      customerName: customerName ?? this.customerName,
      customerImageUrl: customerImageUrl ?? this.customerImageUrl,
      jobTitle: jobTitle ?? this.jobTitle,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RatingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RatingModel(id: $id, fundiId: $fundiId, rating: $rating, review: $review)';
  }
}

/// Fundi rating summary model
class FundiRatingSummary {
  final String fundiId;
  final double averageRating;
  final int totalRatings;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;
  final List<RatingModel> recentRatings;

  const FundiRatingSummary({
    required this.fundiId,
    required this.averageRating,
    required this.totalRatings,
    required this.fiveStarCount,
    required this.fourStarCount,
    required this.threeStarCount,
    required this.twoStarCount,
    required this.oneStarCount,
    required this.recentRatings,
  });

  /// Get rating percentage for a specific star count
  double getRatingPercentage(int starCount) {
    if (totalRatings == 0) return 0.0;
    return (starCount / totalRatings) * 100;
  }

  /// Get formatted average rating
  String get formattedAverageRating {
    return averageRating.toStringAsFixed(1);
  }

  /// Create FundiRatingSummary from JSON
  factory FundiRatingSummary.fromJson(Map<String, dynamic> json) {
    return FundiRatingSummary(
      fundiId: json['fundi_id'] as String,
      averageRating: (json['average_rating'] as num).toDouble(),
      totalRatings: json['total_ratings'] as int,
      fiveStarCount: json['five_star_count'] as int,
      fourStarCount: json['four_star_count'] as int,
      threeStarCount: json['three_star_count'] as int,
      twoStarCount: json['two_star_count'] as int,
      oneStarCount: json['one_star_count'] as int,
      recentRatings:
          (json['recent_ratings'] as List<dynamic>?)
              ?.map(
                (rating) =>
                    RatingModel.fromJson(rating as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// Convert FundiRatingSummary to JSON
  Map<String, dynamic> toJson() {
    return {
      'fundi_id': fundiId,
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'five_star_count': fiveStarCount,
      'four_star_count': fourStarCount,
      'three_star_count': threeStarCount,
      'two_star_count': twoStarCount,
      'one_star_count': oneStarCount,
      'recent_ratings': recentRatings.map((rating) => rating.toJson()).toList(),
    };
  }
}
