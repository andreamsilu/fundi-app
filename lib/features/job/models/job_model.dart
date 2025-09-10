import 'package:flutter/material.dart';

/// Job model representing job postings and applications
class JobModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final double? latitude;
  final double? longitude;
  final double budget;
  final String budgetType; // 'fixed' or 'hourly'
  final JobStatus status;
  final String customerId;
  final String? customerName;
  final String? customerImageUrl;
  final String? assignedFundiId;
  final String? assignedFundiName;
  final String? assignedFundiImageUrl;
  final List<String> imageUrls;
  final List<String> requiredSkills;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.latitude,
    this.longitude,
    required this.budget,
    required this.budgetType,
    required this.status,
    required this.customerId,
    this.customerName,
    this.customerImageUrl,
    this.assignedFundiId,
    this.assignedFundiName,
    this.assignedFundiImageUrl,
    required this.imageUrls,
    required this.requiredSkills,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Check if job is open for applications
  bool get isOpen => status == JobStatus.open;

  /// Check if job is in progress
  bool get isInProgress => status == JobStatus.inProgress;

  /// Check if job is completed
  bool get isCompleted => status == JobStatus.completed;

  /// Check if job is cancelled
  bool get isCancelled => status == JobStatus.cancelled;

  /// Check if job has deadline passed
  bool get isDeadlinePassed => DateTime.now().isAfter(deadline);

  /// Get formatted budget string
  String get formattedBudget {
    final currency = 'TZS'; // Tanzanian Shilling
    if (budgetType == 'hourly') {
      return '$currency ${budget.toStringAsFixed(0)}/hour';
    }
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

  /// Create JobModel from JSON
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      location: json['location'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      budget: (json['budget'] as num).toDouble(),
      budgetType: json['budget_type'] as String,
      status: JobStatus.fromString(json['status'] as String),
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String?,
      customerImageUrl: json['customer_image_url'] as String?,
      assignedFundiId: json['assigned_fundi_id'] as String?,
      assignedFundiName: json['assigned_fundi_name'] as String?,
      assignedFundiImageUrl: json['assigned_fundi_image_url'] as String?,
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      requiredSkills: List<String>.from(json['required_skills'] ?? []),
      deadline: DateTime.parse(json['deadline'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert JobModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'budget': budget,
      'budget_type': budgetType,
      'status': status.value,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_image_url': customerImageUrl,
      'assigned_fundi_id': assignedFundiId,
      'assigned_fundi_name': assignedFundiName,
      'assigned_fundi_image_url': assignedFundiImageUrl,
      'image_urls': imageUrls,
      'required_skills': requiredSkills,
      'deadline': deadline.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  JobModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? location,
    double? latitude,
    double? longitude,
    double? budget,
    String? budgetType,
    JobStatus? status,
    String? customerId,
    String? customerName,
    String? customerImageUrl,
    String? assignedFundiId,
    String? assignedFundiName,
    String? assignedFundiImageUrl,
    List<String>? imageUrls,
    List<String>? requiredSkills,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      budget: budget ?? this.budget,
      budgetType: budgetType ?? this.budgetType,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerImageUrl: customerImageUrl ?? this.customerImageUrl,
      assignedFundiId: assignedFundiId ?? this.assignedFundiId,
      assignedFundiName: assignedFundiName ?? this.assignedFundiName,
      assignedFundiImageUrl:
          assignedFundiImageUrl ?? this.assignedFundiImageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      fundiId: json['fundi_id'] as String,
      fundiName: json['fundi_name'] as String,
      fundiImageUrl: json['fundi_image_url'] as String?,
      message: json['message'] as String,
      proposedBudget: (json['proposed_budget'] as num).toDouble(),
      proposedBudgetType: json['proposed_budget_type'] as String,
      estimatedDays: json['estimated_days'] as int,
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
