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

  /// Create FundiModel from JSON
  factory FundiModel.fromJson(Map<String, dynamic> json) {
    return FundiModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'],
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalJobs: json['totalJobs'] ?? 0,
      completedJobs: json['completedJobs'] ?? 0,
      skills: List<String>.from(json['skills'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      nidaNumber: json['nidaNumber'],
      vetaCertificate: json['vetaCertificate'],
      isVerified: json['isVerified'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      bio: json['bio'],
      hourlyRate: (json['hourlyRate'] ?? 0.0).toDouble(),
      portfolio: Map<String, dynamic>.from(json['portfolio'] ?? {}),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
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
