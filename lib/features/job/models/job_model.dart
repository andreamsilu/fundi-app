import 'package:flutter/material.dart';

/// Job model representing job postings
/// This model follows the API structure exactly
class JobModel {
  final String id;
  final String customerId;
  final String categoryId;
  final String title;
  final String description;
  final double budget;
  final String budgetType;
  final DateTime deadline;
  final double? locationLat;
  final double? locationLng;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional fields for UI/UX (not in API but needed for mobile)
  final String? categoryName;
  final String? location;
  final String? customerName;
  final String? customerImageUrl;
  final List<String>? imageUrls;
  final List<String>? requiredSkills;
  final Map<String, dynamic>? metadata;

  const JobModel({
    required this.id,
    required this.customerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.budget,
    required this.budgetType,
    required this.deadline,
    this.locationLat,
    this.locationLng,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.location,
    this.customerName,
    this.customerImageUrl,
    this.imageUrls,
    this.requiredSkills,
    this.metadata,
  });

  /// Check if job is open for applications
  bool get isOpen => status == 'open';

  /// Check if job is in progress
  bool get isInProgress => status == 'in_progress';

  /// Check if job is completed
  bool get isCompleted => status == 'completed';

  /// Check if job is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Check if job has deadline passed
  bool get isDeadlinePassed => DateTime.now().isAfter(deadline);

  /// Get formatted budget string
  String get formattedBudget {
    final currency = 'TZS'; // Tanzanian Shilling
    return '$currency ${budget.toStringAsFixed(0)}';
  }

  /// Get time remaining until deadline
  Duration get timeRemaining => deadline.difference(DateTime.now());

  /// Get formatted time remaining
  String get formattedTimeRemaining {
    final remaining = timeRemaining;
    if (remaining.isNegative) {
      return 'Deadline passed';
    }

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} remaining';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} remaining';
    } else {
      return 'Less than 1 hour remaining';
    }
  }

  /// Get formatted deadline
  String get formattedDeadline {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Deadline passed';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} left';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} left';
    } else {
      return 'Less than 1 hour left';
    }
  }

  /// Get category (alias for categoryName)
  String? get category => categoryName;

  /// Create JobModel from JSON (follows API structure)
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id']
          .toString(), // Convert to String to handle both int and String
      customerId: json['customer_id']
          .toString(), // Convert to String to handle both int and String
      categoryId: json['category_id']
          .toString(), // Convert to String to handle both int and String
      title: json['title'] as String,
      description: json['description'] as String,
      budget: JobModel.parseDouble(json['budget']),
      budgetType: json['budget_type'] as String? ?? 'fixed',
      deadline: DateTime.parse(json['deadline'] as String),
      locationLat: json['location_lat'] != null
          ? JobModel.parseDouble(json['location_lat'])
          : null,
      locationLng: json['location_lng'] != null
          ? JobModel.parseDouble(json['location_lng'])
          : null,
      status: json['status'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      categoryName: json['category'] != null
          ? (json['category'] as Map<String, dynamic>)['name'] as String?
          : json['category_name']
                as String?, // Handle nested category or direct field
      location: json['location'] as String?, // Additional field for mobile
      customerName: json['customer'] != null
          ? (json['customer'] as Map<String, dynamic>)['phone'] as String?
          : json['customer_name']
                as String?, // Handle nested customer or direct field
      customerImageUrl:
          json['customer_image_url'] as String?, // Additional field for mobile
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'] as List)
          : null, // Additional field for mobile
      requiredSkills: json['required_skills'] != null
          ? List<String>.from(json['required_skills'] as List)
          : null, // Additional field for mobile
      metadata: json['metadata'] != null
          ? json['metadata'] as Map<String, dynamic>
          : null, // Additional field for mobile
    );
  }

  /// Convert JobModel to JSON (follows API structure exactly)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'budget': budget,
      'budget_type': budgetType,
      'deadline': deadline.toIso8601String(),
      'location_lat': locationLat,
      'location_lng': locationLng,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  JobModel copyWith({
    String? id,
    String? customerId,
    String? categoryId,
    String? title,
    String? description,
    double? budget,
    String? budgetType,
    DateTime? deadline,
    double? locationLat,
    double? locationLng,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
    String? location,
    String? customerName,
    String? customerImageUrl,
    List<String>? imageUrls,
    List<String>? requiredSkills,
    Map<String, dynamic>? metadata,
  }) {
    return JobModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      budgetType: budgetType ?? this.budgetType,
      deadline: deadline ?? this.deadline,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      location: location ?? this.location,
      customerName: customerName ?? this.customerName,
      customerImageUrl: customerImageUrl ?? this.customerImageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'JobModel(id: $id, title: $title, status: $status, budget: $formattedBudget)';
  }

  /// Helper method to parse double values from JSON (handles both String and num)
  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper method to parse int values from JSON (handles both String and num)
  static int parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

/// Job status enumeration
enum JobStatus {
  open('open'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  const JobStatus(this.value);
  final String value;

  static JobStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'open':
        return JobStatus.open;
      case 'in_progress':
        return JobStatus.inProgress;
      case 'completed':
        return JobStatus.completed;
      case 'cancelled':
        return JobStatus.cancelled;
      default:
        throw ArgumentError('Invalid job status: $value');
    }
  }

  String get displayName {
    switch (this) {
      case JobStatus.open:
        return 'Open';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color toColor() {
    switch (this) {
      case JobStatus.open:
        return Colors.green;
      case JobStatus.inProgress:
        return Colors.orange;
      case JobStatus.completed:
        return Colors.blue;
      case JobStatus.cancelled:
        return Colors.red;
    }
  }
}

/// Job application model
class JobApplicationModel {
  final String id;
  final String jobId;
  final String fundiId;
  final String fundiName;
  final String? fundiImageUrl;
  final String message;
  final double proposedBudget;
  final String proposedBudgetType;
  final int estimatedDays;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.fundiId,
    required this.fundiName,
    this.fundiImageUrl,
    required this.message,
    required this.proposedBudget,
    required this.proposedBudgetType,
    required this.estimatedDays,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get formatted proposed budget
  String get formattedProposedBudget {
    final currency = 'TZS';
    if (proposedBudgetType == 'hourly') {
      return '$currency ${proposedBudget.toStringAsFixed(0)}/hour';
    }
    return '$currency ${proposedBudget.toStringAsFixed(0)}';
  }

  /// Create JobApplicationModel from JSON
  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id']
          .toString(), // Convert to String to handle both int and String
      jobId: json['job_id']
          .toString(), // Convert to String to handle both int and String
      fundiId: json['fundi_id']
          .toString(), // Convert to String to handle both int and String
      fundiName: json['fundi_name'] as String,
      fundiImageUrl: json['fundi_image_url'] as String?,
      message: json['message'] as String,
      proposedBudget: JobModel.parseDouble(json['proposed_budget']),
      proposedBudgetType: json['proposed_budget_type'] as String,
      estimatedDays: JobModel.parseInt(
        json['estimated_days'],
      ), // Convert to int safely
      status: ApplicationStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert JobApplicationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'fundi_id': fundiId,
      'fundi_name': fundiName,
      'fundi_image_url': fundiImageUrl,
      'message': message,
      'proposed_budget': proposedBudget,
      'proposed_budget_type': proposedBudgetType,
      'estimated_days': estimatedDays,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Application status enumeration
enum ApplicationStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected'),
  withdrawn('withdrawn');

  const ApplicationStatus(this.value);
  final String value;

  static ApplicationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'withdrawn':
        return ApplicationStatus.withdrawn;
      default:
        throw ArgumentError('Invalid application status: $value');
    }
  }

  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}
