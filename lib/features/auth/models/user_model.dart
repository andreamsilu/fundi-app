/// User model representing user data throughout the application
/// This model follows the API structure exactly
class UserModel {
  final String id;
  final String phone; // Primary identifier (matches API)
  final String? password; // Hidden in API responses
  final List<UserRole> roles; // Multiple roles: ['customer', 'fundi', 'admin']
  final List<int> roleIds; // Role IDs: [1, 2, 3] for efficient API operations
  final UserStatus status; // User status
  final String? nidaNumber; // National ID number
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional fields for UI/UX (not in API but needed for mobile)
  final String? email; // Optional email for notifications
  final String? fullName; // Computed from FundiProfile if available
  final String? profileImageUrl; // Profile image URL
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.phone,
    this.password,
    required this.roles,
    required this.roleIds,
    required this.status,
    this.nidaNumber,
    this.createdAt,
    this.updatedAt,
    this.email,
    this.fullName,
    this.profileImageUrl,
    this.metadata,
  });

  /// Get display name (full name or phone if no name)
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    return phone;
  }

  /// Get short display name (first name or phone)
  String get shortDisplayName {
    if (fullName != null && fullName!.isNotEmpty) {
      final names = fullName!.split(' ');
      return names.isNotEmpty ? names.first : phone;
    }
    return phone;
  }

  /// Check if user is a customer
  bool get isCustomer => roles.contains(UserRole.customer);

  /// Check if user is a fundi (craftsman)
  bool get isFundi => roles.contains(UserRole.fundi);

  /// Check if user is admin
  bool get isAdmin => roles.contains(UserRole.admin);

  /// Get primary role (first role in the list)
  UserRole get primaryRole =>
      roles.isNotEmpty ? roles.first : UserRole.customer;

  /// Check if user has multiple roles
  bool get hasMultipleRoles => roles.length > 1;

  /// Get role IDs as list of integers
  List<int> get roleIdList => roleIds;

  /// Check if user has specific role by ID
  bool hasRoleById(int roleId) => roleIds.contains(roleId);

  /// Check if user has any of the specified role IDs
  bool hasAnyRoleByIds(List<int> roleIds) {
    return this.roleIds.any((id) => roleIds.contains(id));
  }

  /// Check if user is active
  bool get isActive => status == UserStatus.active;

  /// Check if user is verified
  bool get isVerified => status == UserStatus.verified;

  /// Get user type (alias for primary role)
  String get userType => primaryRole.value;

  /// Get first name from full name
  String? get firstName {
    if (fullName != null && fullName!.isNotEmpty) {
      final names = fullName!.split(' ');
      return names.isNotEmpty ? names.first : null;
    }
    return null;
  }

  /// Create UserModel from JSON (follows JWT API structure)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle JWT API response structure
    List<UserRole> roles = [];
    List<int> roleIds = [];
    
    // Extract roles from JWT API response
    if (json['roles'] != null) {
      final rolesList = json['roles'] as List<dynamic>;
      roles = rolesList.map((role) {
        if (role is Map<String, dynamic>) {
          return UserRole.fromString(role['name'] as String);
        } else if (role is String) {
          return UserRole.fromString(role);
        }
        return UserRole.customer;
      }).toList();
      
      // Extract role IDs
      roleIds = rolesList.map((role) {
        if (role is Map<String, dynamic>) {
          return role['id'] as int;
        }
        return 1; // Default customer role ID
      }).toList();
    }
    
    // Fallback to role_names if roles array is not available
    if (roles.isEmpty && json['role_names'] != null) {
      final roleNames = json['role_names'] as List<dynamic>;
      roles = roleNames.map((roleName) => UserRole.fromString(roleName as String)).toList();
    }
    
    // Default to customer role if no roles found
    if (roles.isEmpty) {
      roles = [UserRole.customer];
      roleIds = [1];
    }

    return UserModel(
      id: json['id'].toString(), // Convert to String to handle both int and String
      phone: json['phone'] as String,
      password: json['password'] as String?, // Usually hidden in API responses
      roles: roles,
      roleIds: roleIds,
      status: json['status'] != null
          ? UserStatus.fromString(json['status'] as String)
          : UserStatus.active, // Default to active if not provided
      nidaNumber: json['nida_number'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      email: json['email'] as String?, // Additional field for mobile
      fullName: json['full_name'] as String?, // Additional field for mobile
      profileImageUrl: json['profile_image_url'] as String?, // Additional field for mobile
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert UserModel to JSON (follows API structure)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'password': password, // Usually not sent in API requests
      'roles': roles.map((role) => role.value).toList(),
      'role_ids': roleIds, // Include role IDs for API operations
      'status': status.value,
      'nida_number': nidaNumber,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'email': email, // Additional field for mobile
      'full_name': fullName, // Additional field for mobile
      'profile_image_url': profileImageUrl, // Additional field for mobile
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? phone,
    String? password,
    List<UserRole>? roles,
    List<int>? roleIds,
    UserStatus? status,
    String? nidaNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? email,
    String? fullName,
    String? profileImageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      roles: roles ?? this.roles,
      roleIds: roleIds ?? this.roleIds,
      status: status ?? this.status,
      nidaNumber: nidaNumber ?? this.nidaNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
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
    return 'UserModel(id: $id, phone: $phone, fullName: $fullName, roles: $roles, status: $status)';
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
