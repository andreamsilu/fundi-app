/// Fundi application model for users applying to become fundi
/// Represents the application data structure for fundi registration
class FundiApplicationModel {
  final String id;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String nidaNumber;
  final String vetaCertificate;
  final String location;
  final String bio;
  final List<String> skills;
  final List<String> languages;
  final List<String> portfolioImages;
  final ApplicationStatus status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FundiApplicationModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.nidaNumber,
    required this.vetaCertificate,
    required this.location,
    required this.bio,
    required this.skills,
    required this.languages,
    required this.portfolioImages,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create FundiApplicationModel from JSON
  factory FundiApplicationModel.fromJson(Map<String, dynamic> json) {
    return FundiApplicationModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      nidaNumber: json['nida_number'] as String,
      vetaCertificate: json['veta_certificate'] as String,
      location: json['location'] as String,
      bio: json['bio'] as String,
      skills: List<String>.from(json['skills'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      portfolioImages: List<String>.from(json['portfolio_images'] ?? []),
      status: ApplicationStatus.fromString(json['status'] as String),
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert FundiApplicationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'nida_number': nidaNumber,
      'veta_certificate': vetaCertificate,
      'location': location,
      'bio': bio,
      'skills': skills,
      'languages': languages,
      'portfolio_images': portfolioImages,
      'status': status.value,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  FundiApplicationModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? nidaNumber,
    String? vetaCertificate,
    String? location,
    String? bio,
    List<String>? skills,
    List<String>? languages,
    List<String>? portfolioImages,
    ApplicationStatus? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FundiApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      nidaNumber: nidaNumber ?? this.nidaNumber,
      vetaCertificate: vetaCertificate ?? this.vetaCertificate,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if application is pending
  bool get isPending => status == ApplicationStatus.pending;

  /// Check if application is approved
  bool get isApproved => status == ApplicationStatus.approved;

  /// Check if application is rejected
  bool get isRejected => status == ApplicationStatus.rejected;

  /// Get status display text
  String get statusDisplayText => status.displayName;

  /// Get formatted creation date
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FundiApplicationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FundiApplicationModel(id: $id, userId: $userId, fullName: $fullName, status: $status)';
  }
}

/// Application status enum
enum ApplicationStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const ApplicationStatus(this.value);
  final String value;

  static ApplicationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'approved':
        return ApplicationStatus.approved;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        throw ArgumentError('Invalid application status: $value');
    }
  }

  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending Review';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  String get description {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Your application is being reviewed by our team';
      case ApplicationStatus.approved:
        return 'Congratulations! Your application has been approved';
      case ApplicationStatus.rejected:
        return 'Your application was not approved. Please review the feedback';
    }
  }
}
