import 'dart:convert';

/// Fundi model representing a skilled worker's profile and information
class FundiModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String location;
  final double rating;
  final int totalJobs;
  final int completedJobs;
  final List<String> skills;
  final List<String> certifications;
  final String? nidaNumber;
  final String? vetaCertificate;
  final bool isVerified;
  final bool isAvailable;
  final String? bio;
  final double hourlyRate;
  final Map<String, dynamic> portfolio;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FundiModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.location,
    required this.rating,
    required this.totalJobs,
    required this.completedJobs,
    required this.skills,
    required this.certifications,
    this.nidaNumber,
    this.vetaCertificate,
    required this.isVerified,
    required this.isAvailable,
    this.bio,
    required this.hourlyRate,
    required this.portfolio,
    required this.createdAt,
    required this.updatedAt,
  });

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

  /// Create FundiModel from JSON
  factory FundiModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle nested fundi_profile data
      final fundiProfile = json['fundi_profile'] as Map<String, dynamic>?;

      // Parse skills from JSON string or array
      List<String> skills = [];
      if (fundiProfile?['skills'] != null) {
        final skillsData = fundiProfile!['skills'];
        if (skillsData is String) {
          try {
            // Parse JSON string like "[\"Plumbing\",\"Pipe Repair\",\"Installation\"]"
            final decoded = jsonDecode(skillsData) as List<dynamic>;
            skills = List<String>.from(decoded);
          } catch (e) {
            // If parsing fails, treat as comma-separated string
            skills = skillsData
                .split(',')
                .map((s) => s.trim().replaceAll('"', ''))
                .toList();
          }
        } else if (skillsData is List) {
          skills = List<String>.from(skillsData);
        }
      } else if (json['skills'] != null) {
        skills = List<String>.from(json['skills'] ?? []);
      }

      // Handle portfolio data - use visible_portfolio if available, otherwise portfolio_items
      Map<String, dynamic> portfolio = {};
      if (json['visible_portfolio'] != null) {
        // Process portfolio items to handle is_visible field conversion
        final portfolioItems = json['visible_portfolio'] as List<dynamic>;
        final processedItems = portfolioItems.map((item) {
          if (item is Map<String, dynamic>) {
            // Convert is_visible from int to bool if present
            if (item.containsKey('is_visible')) {
              final isVisible = item['is_visible'];
              if (isVisible is int) {
                item['is_visible'] = isVisible == 1;
              } else if (isVisible is bool) {
                // Already boolean, keep as is
              } else {
                // Handle null or other types
                item['is_visible'] = false;
              }
            }
          }
          return item;
        }).toList();
        portfolio = {'items': processedItems};
      } else if (json['portfolio_items'] != null) {
        // Process portfolio items to handle is_visible field conversion
        final portfolioItems = json['portfolio_items'] as List<dynamic>;
        final processedItems = portfolioItems.map((item) {
          if (item is Map<String, dynamic>) {
            // Convert is_visible from int to bool if present
            if (item.containsKey('is_visible')) {
              final isVisible = item['is_visible'];
              if (isVisible is int) {
                item['is_visible'] = isVisible == 1;
              } else if (isVisible is bool) {
                // Already boolean, keep as is
              } else {
                // Handle null or other types
                item['is_visible'] = false;
              }
            }
          }
          return item;
        }).toList();
        portfolio = {'items': processedItems};
      } else if (json['portfolio'] != null) {
        portfolio = Map<String, dynamic>.from(json['portfolio']);
      }

      // Calculate location from lat/lng if available
      String location = '';
      if (fundiProfile?['location_lat'] != null &&
          fundiProfile?['location_lng'] != null) {
        location =
            '${fundiProfile!['location_lat']}, ${fundiProfile['location_lng']}';
      } else if (fundiProfile?['location'] != null) {
        location = fundiProfile!['location'];
      } else if (json['location'] != null) {
        location = json['location'];
      }

      return FundiModel(
        id: json['id']?.toString() ?? '',
        name:
            fundiProfile?['full_name'] ??
            json['full_name'] ??
            json['name'] ??
            '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        profileImage: json['profile_image'] ?? json['profileImage'],
        location: location,
        rating: (json['rating'] ?? 0.0).toDouble(),
        totalJobs: json['total_jobs'] ?? json['totalJobs'] ?? 0,
        completedJobs: json['completed_jobs'] ?? json['completedJobs'] ?? 0,
        skills: skills,
        certifications: List<String>.from(json['certifications'] ?? []),
        nidaNumber: json['nida_number'] ?? json['nidaNumber'],
        vetaCertificate:
            fundiProfile?['veta_certificate'] ??
            json['veta_certificate'] ??
            json['vetaCertificate'],
        isVerified:
            (fundiProfile?['verification_status'] == 'approved') ||
            _parseBooleanSafely(json['is_verified']) ||
            _parseBooleanSafely(json['isVerified']),
        isAvailable:
            _parseBooleanSafely(json['is_available']) ||
            _parseBooleanSafely(json['isAvailable']) ||
            (json['status']?.toString() == 'active') ||
            (json['status'] == null),
        bio: fundiProfile?['bio'] ?? json['bio'],
        hourlyRate: (json['hourly_rate'] ?? json['hourlyRate'] ?? 0.0)
            .toDouble(),
        portfolio: portfolio,
        createdAt: DateTime.parse(
          json['created_at'] ??
              json['createdAt'] ??
              DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          json['updated_at'] ??
              json['updatedAt'] ??
              DateTime.now().toIso8601String(),
        ),
      );
    } catch (e) {
      // Return empty fundi model if parsing fails
      print('Error parsing FundiModel: $e');
      return FundiModel.empty();
    }
  }

  /// Convert FundiModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'location': location,
      'rating': rating,
      'totalJobs': totalJobs,
      'completedJobs': completedJobs,
      'skills': skills,
      'certifications': certifications,
      'nidaNumber': nidaNumber,
      'vetaCertificate': vetaCertificate,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'bio': bio,
      'hourlyRate': hourlyRate,
      'portfolio': portfolio,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create empty FundiModel
  factory FundiModel.empty() {
    final now = DateTime.now();
    return FundiModel(
      id: '',
      name: '',
      email: '',
      phone: '',
      location: '',
      rating: 0.0,
      totalJobs: 0,
      completedJobs: 0,
      skills: [],
      certifications: [],
      isVerified: false,
      isAvailable: true,
      hourlyRate: 0.0,
      portfolio: {},
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Copy with new values
  FundiModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? location,
    double? rating,
    int? totalJobs,
    int? completedJobs,
    List<String>? skills,
    List<String>? certifications,
    String? nidaNumber,
    String? vetaCertificate,
    bool? isVerified,
    bool? isAvailable,
    String? bio,
    double? hourlyRate,
    Map<String, dynamic>? portfolio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FundiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      totalJobs: totalJobs ?? this.totalJobs,
      completedJobs: completedJobs ?? this.completedJobs,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      nidaNumber: nidaNumber ?? this.nidaNumber,
      vetaCertificate: vetaCertificate ?? this.vetaCertificate,
      isVerified: isVerified ?? this.isVerified,
      isAvailable: isAvailable ?? this.isAvailable,
      bio: bio ?? this.bio,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      portfolio: portfolio ?? this.portfolio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get completion rate percentage
  double get completionRate {
    if (totalJobs == 0) return 0.0;
    return (completedJobs / totalJobs) * 100;
  }

  /// Check if fundi has specific skill
  bool hasSkill(String skill) {
    return skills.any((s) => s.toLowerCase().contains(skill.toLowerCase()));
  }

  /// Get formatted hourly rate
  String get formattedHourlyRate {
    return 'TSh ${hourlyRate.toStringAsFixed(0)}/hour';
  }

  /// Get status text
  String get statusText {
    if (!isAvailable) return 'Busy';
    if (isVerified) return 'Verified & Available';
    return 'Available';
  }
}
