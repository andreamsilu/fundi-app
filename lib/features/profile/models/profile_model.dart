/// Profile model representing user profile information
/// Extends user model with additional profile-specific data
class ProfileModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Profile-specific fields
  final String? bio;
  final String? location;
  final String? nidaNumber;
  final String? vetaCertificate;
  final List<String> skills;
  final List<String> languages;
  final double? rating;
  final int totalJobs;
  final int completedJobs;
  final int totalEarnings;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastSeen;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? metadata;

  const ProfileModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.bio,
    this.location,
    this.nidaNumber,
    this.vetaCertificate,
    this.skills = const [],
    this.languages = const [],
    this.rating,
    this.totalJobs = 0,
    this.completedJobs = 0,
    this.totalEarnings = 0,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeen,
    this.preferences,
    this.metadata,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get display name (first name + last initial)
  String get displayName {
    if (lastName.isNotEmpty) {
      return '$firstName ${lastName[0].toUpperCase()}.';
    }
    return firstName;
  }

  /// Get initials for avatar
  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  /// Check if user is a customer
  bool get isCustomer => role == UserRole.customer;

  /// Check if user is a fundi (craftsman)
  bool get isFundi => role == UserRole.fundi;

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is active
  bool get isActive => status == UserStatus.active;

  /// Check if user has verified status
  bool get hasVerifiedStatus => status == UserStatus.verified;

  /// Get completion rate
  double get completionRate {
    if (totalJobs == 0) return 0.0;
    return (completedJobs / totalJobs) * 100;
  }

  /// Get average rating display
  String get ratingDisplay {
    if (rating == null) return 'No rating';
    return rating!.toStringAsFixed(1);
  }

  /// Get earnings display
  String get earningsDisplay {
    if (totalEarnings >= 1000000) {
      return '${(totalEarnings / 1000000).toStringAsFixed(1)}M TZS';
    } else if (totalEarnings >= 1000) {
      return '${(totalEarnings / 1000).toStringAsFixed(1)}K TZS';
    } else {
      return '$totalEarnings TZS';
    }
  }

  /// Get online status text
  String get onlineStatusText {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Offline';

    final now = DateTime.now();
    final difference = now.difference(lastSeen!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Get verification status text
  String get verificationStatusText {
    if (isVerified) return 'Verified';
    if (nidaNumber != null) return 'Pending verification';
    return 'Not verified';
  }

  /// Create ProfileModel from JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Derive role safely from either 'roles' array or fallback 'role' string
    final List<String> rolesList =
        (json['roles'] as List?)?.map((role) => role.toString()).toList() ??
        const <String>[];
    final String derivedRole = rolesList.isNotEmpty
        ? rolesList.first
        : (json['role'] as String? ?? 'customer');

    return ProfileModel(
      id: json['id'].toString(),
      email: json['email'] as String? ?? '',
      firstName:
          json['first_name'] as String? ?? json['name'] as String? ?? 'User',
      lastName: json['last_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? json['phone'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      role: UserRole.fromString(derivedRole),
      status: UserStatus.fromString(json['status'] as String? ?? 'active'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      nidaNumber: json['nida_number'] as String?,
      vetaCertificate: json['veta_certificate'] as String?,
      skills: List<String>.from(json['skills'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      rating: json['rating'] as double?,
      totalJobs: json['total_jobs'] as int? ?? 0,
      completedJobs: json['completed_jobs'] as int? ?? 0,
      totalEarnings: json['total_earnings'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
      preferences: json['preferences'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert ProfileModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'role': role.value,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'bio': bio,
      'location': location,
      'nida_number': nidaNumber,
      'veta_certificate': vetaCertificate,
      'skills': skills,
      'languages': languages,
      'rating': rating,
      'total_jobs': totalJobs,
      'completed_jobs': completedJobs,
      'total_earnings': totalEarnings,
      'is_verified': isVerified,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'preferences': preferences,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  ProfileModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    UserRole? role,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bio,
    String? location,
    String? nidaNumber,
    String? vetaCertificate,
    List<String>? skills,
    List<String>? languages,
    double? rating,
    int? totalJobs,
    int? completedJobs,
    int? totalEarnings,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastSeen,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      nidaNumber: nidaNumber ?? this.nidaNumber,
      vetaCertificate: vetaCertificate ?? this.vetaCertificate,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      rating: rating ?? this.rating,
      totalJobs: totalJobs ?? this.totalJobs,
      completedJobs: completedJobs ?? this.completedJobs,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      preferences: preferences ?? this.preferences,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProfileModel(id: $id, fullName: $fullName, role: $role, status: $status)';
  }
}

/// User roles in the application
enum UserRole {
  customer('customer'),
  fundi('fundi'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'fundi':
        return UserRole.fundi;
      case 'admin':
        return UserRole.admin;
      default:
        throw ArgumentError('Invalid user role: $value');
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.fundi:
        return 'Fundi';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

/// User status in the application
enum UserStatus {
  pending('pending'),
  active('active'),
  verified('verified'),
  suspended('suspended'),
  deleted('deleted');

  const UserStatus(this.value);
  final String value;

  static UserStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return UserStatus.pending;
      case 'active':
        return UserStatus.active;
      case 'verified':
        return UserStatus.verified;
      case 'suspended':
        return UserStatus.suspended;
      case 'deleted':
        return UserStatus.deleted;
      default:
        throw ArgumentError('Invalid user status: $value');
    }
  }

  String get displayName {
    switch (this) {
      case UserStatus.pending:
        return 'Pending';
      case UserStatus.active:
        return 'Active';
      case UserStatus.verified:
        return 'Verified';
      case UserStatus.suspended:
        return 'Suspended';
      case UserStatus.deleted:
        return 'Deleted';
    }
  }
}
