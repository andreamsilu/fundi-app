/// FundiProfile model representing fundi-specific data
/// This model follows the API structure exactly
class FundiProfileModel {
  final String id;
  final String userId;
  final String fullName;
  final double? locationLat;
  final double? locationLng;
  final String? verificationStatus;
  final String? vetaCertificate;
  final List<String>? skills;
  final int? experienceYears;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FundiProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.locationLat,
    this.locationLng,
    this.verificationStatus,
    this.vetaCertificate,
    this.skills,
    this.experienceYears,
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  /// Get location as a string
  String get locationString {
    if (locationLat != null && locationLng != null) {
      return '${locationLat!.toStringAsFixed(6)}, ${locationLng!.toStringAsFixed(6)}';
    }
    return 'Location not set';
  }

  /// Check if fundi is verified
  bool get isVerified => verificationStatus == 'verified';

  /// Check if fundi has VETA certificate
  bool get hasVetaCertificate => vetaCertificate != null && vetaCertificate!.isNotEmpty;

  /// Get skills as comma-separated string
  String get skillsString {
    if (skills == null || skills!.isEmpty) return 'No skills listed';
    return skills!.join(', ');
  }

  /// Get experience display string
  String get experienceDisplay {
    if (experienceYears == null) return 'No experience listed';
    if (experienceYears == 1) return '1 year experience';
    return '$experienceYears years experience';
  }

  /// Create FundiProfileModel from JSON (follows API structure)
  factory FundiProfileModel.fromJson(Map<String, dynamic> json) {
    return FundiProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      locationLat: json['location_lat'] != null ? (json['location_lat'] as num).toDouble() : null,
      locationLng: json['location_lng'] != null ? (json['location_lng'] as num).toDouble() : null,
      verificationStatus: json['verification_status'] as String?,
      vetaCertificate: json['veta_certificate'] as String?,
      skills: json['skills'] != null ? List<String>.from(json['skills'] as List) : null,
      experienceYears: json['experience_years'] as int?,
      bio: json['bio'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  /// Convert FundiProfileModel to JSON (follows API structure)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'verification_status': verificationStatus,
      'veta_certificate': vetaCertificate,
      'skills': skills,
      'experience_years': experienceYears,
      'bio': bio,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  FundiProfileModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    double? locationLat,
    double? locationLng,
    String? verificationStatus,
    String? vetaCertificate,
    List<String>? skills,
    int? experienceYears,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FundiProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      vetaCertificate: vetaCertificate ?? this.vetaCertificate,
      skills: skills ?? this.skills,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FundiProfileModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FundiProfileModel(id: $id, userId: $userId, fullName: $fullName, verificationStatus: $verificationStatus)';
  }
}

/// Verification status enumeration
enum VerificationStatus {
  pending('pending'),
  verified('verified'),
  rejected('rejected');

  const VerificationStatus(this.value);
  final String value;

  static VerificationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        throw ArgumentError('Invalid verification status: $value');
    }
  }

  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending Verification';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }
}
