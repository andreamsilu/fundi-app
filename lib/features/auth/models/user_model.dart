/// User model representing user data throughout the application
class UserModel {
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
  final Map<String, dynamic>? metadata;

  const UserModel({
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

  /// Check if user is a customer
  bool get isCustomer => role == UserRole.customer;

  /// Check if user is a fundi (craftsman)
  bool get isFundi => role == UserRole.fundi;

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is active
  bool get isActive => status == UserStatus.active;

  /// Check if user is verified
  bool get isVerified => status == UserStatus.verified;

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      role: UserRole.fromString(json['role'] as String),
      status: UserStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert UserModel to JSON
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
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
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
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
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
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, role: $role, status: $status)';
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

