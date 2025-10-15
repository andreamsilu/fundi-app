import 'dart:convert';
import 'package:fundi/features/portfolio/models/portfolio_model.dart';
import 'package:fundi/features/rating/models/rating_model.dart';

/// Comprehensive fundi profile model that combines all fundi-related data
/// This model aggregates data from multiple sources for a complete fundi profile
class ComprehensiveFundiProfile {
  /// Ultra-safe boolean parsing that handles any type of input
  static bool _parseBooleanSafely(dynamic value) {
    try {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        final lowerValue = value.toLowerCase().trim();
        return lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes';
      }
      if (value is double) return value == 1.0;
      if (value is num) return value.toInt() == 1;
      // Handle any other type by converting to string and checking
      final stringValue = value.toString().toLowerCase().trim();
      return stringValue == 'true' ||
          stringValue == '1' ||
          stringValue == 'yes';
    } catch (e) {
      // If anything goes wrong, return false
      return false;
    }
  }

  // Personal Details
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final double? locationLat;
  final double? locationLng;
  final String? address;
  final String? profileImage;

  // Fundi Category & Skills
  final List<String> skills;
  final String? primaryCategory;
  final int? experienceYears;
  final String? bio;

  // Certifications
  final String? vetaCertificate;
  final List<String> otherCertifications;
  final String verificationStatus;

  // Recent Works (Portfolio)
  final List<PortfolioModel> recentWorks;
  final int totalPortfolioItems;

  // Reviews & Ratings
  final double averageRating;
  final int totalRatings;
  final List<RatingModel> recentReviews;
  final FundiRatingSummary ratingSummary;

  // Availability Status
  final bool isAvailable;
  final String? availabilityStatus;
  final DateTime? lastActiveAt;

  // Additional Info
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const ComprehensiveFundiProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    this.locationLat,
    this.locationLng,
    this.address,
    this.profileImage,
    required this.skills,
    this.primaryCategory,
    this.experienceYears,
    this.bio,
    this.vetaCertificate,
    required this.otherCertifications,
    required this.verificationStatus,
    required this.recentWorks,
    required this.totalPortfolioItems,
    required this.averageRating,
    required this.totalRatings,
    required this.recentReviews,
    required this.ratingSummary,
    required this.isAvailable,
    this.availabilityStatus,
    this.lastActiveAt,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// Get location as a formatted string
  String get locationString {
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    if (locationLat != null && locationLng != null) {
      return '${locationLat!.toStringAsFixed(6)}, ${locationLng!.toStringAsFixed(6)}';
    }
    return 'Location not set';
  }

  /// Check if fundi is verified
  bool get isVerified => verificationStatus == 'verified';

  /// Check if fundi has VETA certificate
  bool get hasVetaCertificate =>
      vetaCertificate != null && vetaCertificate!.isNotEmpty;

  /// Get skills as comma-separated string
  String get skillsString {
    if (skills.isEmpty) return 'No skills listed';
    return skills.join(', ');
  }

  /// Get experience display string
  String get experienceDisplay {
    if (experienceYears == null) return 'No experience listed';
    if (experienceYears == 1) return '1 year experience';
    return '$experienceYears years experience';
  }

  /// Get formatted average rating
  String get formattedAverageRating {
    return averageRating.toStringAsFixed(1);
  }

  /// Get star rating display
  String get starRating {
    final rating = averageRating.round();
    return '★' * rating + '☆' * (5 - rating);
  }

  /// Get availability status display
  String get availabilityDisplay {
    if (!isAvailable) return 'Not Available';
    if (availabilityStatus != null) return availabilityStatus!;
    return 'Available';
  }

  /// Get verification status display
  String get verificationDisplay {
    switch (verificationStatus.toLowerCase()) {
      case 'verified':
        return 'Verified ✓';
      case 'pending':
        return 'Pending Verification';
      case 'rejected':
        return 'Verification Rejected';
      default:
        return 'Not Verified';
    }
  }

  /// Get certification display
  String get certificationDisplay {
    final certs = <String>[];
    if (hasVetaCertificate) certs.add('VETA Certified');
    certs.addAll(otherCertifications);
    if (certs.isEmpty) return 'No certifications';
    return certs.join(', ');
  }

  /// Get recent works count
  String get recentWorksDisplay {
    if (recentWorks.isEmpty) return 'No recent works';
    if (recentWorks.length == 1) return '1 recent work';
    return '${recentWorks.length} recent works';
  }

  /// Get rating display
  String get ratingDisplay {
    if (totalRatings == 0) return 'No ratings yet';
    return '$formattedAverageRating ($totalRatings review${totalRatings > 1 ? 's' : ''})';
  }

  /// Create ComprehensiveFundiProfile from JSON
  factory ComprehensiveFundiProfile.fromJson(Map<String, dynamic> json) {
    // Parse user data
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final fundiProfile = json['fundi_profile'] as Map<String, dynamic>? ?? {};

    // Parse skills - check both fundiProfile and root json
    List<String> skills = [];
    final skillsSource = fundiProfile['skills'] ?? json['skills'];
    if (skillsSource != null) {
      if (skillsSource is String) {
        try {
          final decoded = jsonDecode(skillsSource) as List<dynamic>;
          skills = List<String>.from(decoded);
        } catch (e) {
          skills = skillsSource
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      } else if (skillsSource is List) {
        skills = List<String>.from(skillsSource);
      }
    }

    // Parse portfolio items - handle both formats
    List<dynamic> portfolioItems = [];

    // Check for portfolio.items structure (from getFundiProfile API)
    if (json['portfolio'] != null && json['portfolio']['items'] != null) {
      portfolioItems = json['portfolio']['items'] as List<dynamic>;
    }
    // Check for portfolio_items structure (from other APIs)
    else if (json['portfolio_items'] != null) {
      portfolioItems = json['portfolio_items'] as List<dynamic>;
    }
    // Check for portfolioItems structure
    else if (json['portfolioItems'] != null) {
      portfolioItems = json['portfolioItems'] as List<dynamic>;
    }

    final recentWorks = portfolioItems
        .map((item) => PortfolioModel.fromJson(item as Map<String, dynamic>))
        .toList();

    // Parse ratings
    final ratings = json['ratings'] as List<dynamic>? ?? [];
    final recentReviews = ratings
        .map((rating) => RatingModel.fromJson(rating as Map<String, dynamic>))
        .toList();

    // Parse rating summary
    final ratingSummary = json['rating_summary'] != null
        ? FundiRatingSummary.fromJson(
            json['rating_summary'] as Map<String, dynamic>,
          )
        : FundiRatingSummary(
            fundiId: json['id']?.toString() ?? '',
            averageRating: 0.0,
            totalRatings: 0,
            fiveStarCount: 0,
            fourStarCount: 0,
            threeStarCount: 0,
            twoStarCount: 0,
            oneStarCount: 0,
            recentRatings: [],
          );

    // Parse other certifications
    final otherCerts = json['other_certifications'] as List<dynamic>? ?? [];
    final otherCertifications = List<String>.from(otherCerts);

    // Build metadata to include API fields
    Map<String, dynamic> metadata =
        json['metadata'] as Map<String, dynamic>? ?? {};

    // Add additional fields from API response to metadata if not already there
    if (!metadata.containsKey('totalJobs') && json['totalJobs'] != null) {
      metadata['totalJobs'] = json['totalJobs'];
    }
    if (!metadata.containsKey('completedJobs') &&
        json['completedJobs'] != null) {
      metadata['completedJobs'] = json['completedJobs'];
    }
    if (!metadata.containsKey('hourlyRate') && json['hourlyRate'] != null) {
      metadata['hourlyRate'] = (json['hourlyRate'] as num).toDouble();
    }
    if (!metadata.containsKey('nidaNumber') && json['nidaNumber'] != null) {
      metadata['nidaNumber'] = json['nidaNumber'];
    }

    return ComprehensiveFundiProfile(
      id: json['id']?.toString() ?? '',
      fullName:
          fundiProfile['full_name'] ??
          user['full_name'] ??
          json['name'] ??
          'Unknown',
      phone: user['phone'] ?? json['phone'] ?? '',
      email: user['email'] ?? json['email'] ?? '',
      locationLat: fundiProfile['location_lat'] != null
          ? (fundiProfile['location_lat'] as num).toDouble()
          : null,
      locationLng: fundiProfile['location_lng'] != null
          ? (fundiProfile['location_lng'] as num).toDouble()
          : null,
      address: fundiProfile['address'] ?? json['location'] as String?,
      profileImage:
          user['profile_image'] ??
          json['profileImage'] ??
          json['profile_image'],
      skills: skills,
      primaryCategory:
          fundiProfile['primary_category'] ??
          json['primaryCategory'] ??
          json['profession'] as String?,
      experienceYears:
          fundiProfile['experience_years'] ?? json['experienceYears'] as int?,
      bio: fundiProfile['bio'] ?? json['bio'] as String?,
      vetaCertificate:
          fundiProfile['veta_certificate'] ??
          json['vetaCertificate'] as String?,
      otherCertifications: otherCertifications,
      verificationStatus: fundiProfile['verification_status'] ?? 'pending',
      recentWorks: recentWorks,
      totalPortfolioItems:
          json['total_portfolio_items'] as int? ??
          json['totalPortfolioItems'] as int? ??
          recentWorks.length,
      averageRating:
          (json['average_rating'] as num?)?.toDouble() ??
          (json['rating'] as num?)?.toDouble() ??
          0.0,
      totalRatings:
          json['total_ratings'] as int? ?? json['totalRatings'] as int? ?? 0,
      recentReviews: recentReviews,
      ratingSummary: ratingSummary,
      isAvailable:
          _parseBooleanSafely(json['is_available']) ||
          _parseBooleanSafely(json['isAvailable']) ||
          (json['status']?.toString() == 'active') ||
          (json['status'] == null),
      availabilityStatus: json['availability_status'] as String?,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.parse((json['created_at'] ?? json['createdAt']) as String)
          : null,
      updatedAt: json['updated_at'] != null || json['updatedAt'] != null
          ? DateTime.parse((json['updated_at'] ?? json['updatedAt']) as String)
          : null,
      metadata: metadata.isNotEmpty ? metadata : null,
    );
  }

  /// Convert ComprehensiveFundiProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'address': address,
      'profile_image': profileImage,
      'skills': skills,
      'primary_category': primaryCategory,
      'experience_years': experienceYears,
      'bio': bio,
      'veta_certificate': vetaCertificate,
      'other_certifications': otherCertifications,
      'verification_status': verificationStatus,
      'recent_works': recentWorks.map((work) => work.toJson()).toList(),
      'total_portfolio_items': totalPortfolioItems,
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'recent_reviews': recentReviews.map((review) => review.toJson()).toList(),
      'rating_summary': ratingSummary.toJson(),
      'is_available': isAvailable,
      'availability_status': availabilityStatus,
      'last_active_at': lastActiveAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  ComprehensiveFundiProfile copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    double? locationLat,
    double? locationLng,
    String? address,
    String? profileImage,
    List<String>? skills,
    String? primaryCategory,
    int? experienceYears,
    String? bio,
    String? vetaCertificate,
    List<String>? otherCertifications,
    String? verificationStatus,
    List<PortfolioModel>? recentWorks,
    int? totalPortfolioItems,
    double? averageRating,
    int? totalRatings,
    List<RatingModel>? recentReviews,
    FundiRatingSummary? ratingSummary,
    bool? isAvailable,
    String? availabilityStatus,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ComprehensiveFundiProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      skills: skills ?? this.skills,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      vetaCertificate: vetaCertificate ?? this.vetaCertificate,
      otherCertifications: otherCertifications ?? this.otherCertifications,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      recentWorks: recentWorks ?? this.recentWorks,
      totalPortfolioItems: totalPortfolioItems ?? this.totalPortfolioItems,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      recentReviews: recentReviews ?? this.recentReviews,
      ratingSummary: ratingSummary ?? this.ratingSummary,
      isAvailable: isAvailable ?? this.isAvailable,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComprehensiveFundiProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ComprehensiveFundiProfile(id: $id, fullName: $fullName, isVerified: $isVerified, averageRating: $averageRating)';
  }
}
