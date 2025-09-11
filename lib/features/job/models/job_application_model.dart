/// JobApplication model representing job applications
/// This model follows the API structure exactly
class JobApplicationModel {
  final String id;
  final String jobId;
  final String fundiId;
  final Map<String, dynamic>? requirements;
  final Map<String, dynamic>? budgetBreakdown;
  final double? totalBudget;
  final int? estimatedTime;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Additional fields for UI/UX (not in API but needed for mobile)
  final String? fundiName;
  final String? fundiImageUrl;
  final String? jobTitle;
  final String? coverLetter;
  final double? proposedBudget;
  final String? proposedBudgetType;
  final int? estimatedDays;
  final Map<String, dynamic>? metadata;

  const JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.fundiId,
    this.requirements,
    this.budgetBreakdown,
    this.totalBudget,
    this.estimatedTime,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.fundiName,
    this.fundiImageUrl,
    this.jobTitle,
    this.coverLetter,
    this.proposedBudget,
    this.proposedBudgetType,
    this.estimatedDays,
    this.metadata,
  });

  /// Check if application is pending
  bool get isPending => status == 'pending';

  /// Check if application is accepted
  bool get isAccepted => status == 'accepted';

  /// Check if application is rejected
  bool get isRejected => status == 'rejected';

  /// Check if application is withdrawn
  bool get isWithdrawn => status == 'withdrawn';

  /// Get formatted total budget
  String get formattedTotalBudget {
    if (totalBudget == null) return 'Not specified';
    return 'TZS ${totalBudget!.toStringAsFixed(0)}';
  }

  /// Get formatted proposed budget
  String get formattedProposedBudget {
    if (proposedBudget == null) return 'Not specified';
    final currency = 'TZS';
    if (proposedBudgetType == 'hourly') {
      return '$currency ${proposedBudget!.toStringAsFixed(0)}/hour';
    }
    return '$currency ${proposedBudget!.toStringAsFixed(0)}';
  }

  /// Get estimated time display
  String get estimatedTimeDisplay {
    if (estimatedTime == null) return 'Not specified';
    if (estimatedTime! < 60) {
      return '$estimatedTime minutes';
    } else if (estimatedTime! < 1440) {
      final hours = (estimatedTime! / 60).floor();
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      final days = (estimatedTime! / 1440).floor();
      return '$days day${days > 1 ? 's' : ''}';
    }
  }

  /// Get formatted applied date
  String get formattedAppliedAt {
    if (createdAt == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Create JobApplicationModel from JSON (follows API structure)
  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      fundiId: json['fundi_id'] as String,
      requirements: json['requirements'] as Map<String, dynamic>?,
      budgetBreakdown: json['budget_breakdown'] as Map<String, dynamic>?,
      totalBudget: json['total_budget'] != null ? (json['total_budget'] as num).toDouble() : null,
      estimatedTime: json['estimated_time'] as int?,
      status: json['status'] as String,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      fundiName: json['fundi_name'] as String?, // Additional field for mobile
      fundiImageUrl: json['fundi_image_url'] as String?, // Additional field for mobile
      jobTitle: json['job_title'] as String?, // Additional field for mobile
      coverLetter: json['cover_letter'] as String?, // Additional field for mobile
      proposedBudget: json['proposed_budget'] != null ? (json['proposed_budget'] as num).toDouble() : null, // Additional field for mobile
      proposedBudgetType: json['proposed_budget_type'] as String?, // Additional field for mobile
      estimatedDays: json['estimated_days'] as int?, // Additional field for mobile
      metadata: json['metadata'] as Map<String, dynamic>?, // Additional field for mobile
    );
  }

  /// Convert JobApplicationModel to JSON (follows API structure exactly)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'fundi_id': fundiId,
      'requirements': requirements,
      'budget_breakdown': budgetBreakdown,
      'total_budget': totalBudget,
      'estimated_time': estimatedTime,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  JobApplicationModel copyWith({
    String? id,
    String? jobId,
    String? fundiId,
    Map<String, dynamic>? requirements,
    Map<String, dynamic>? budgetBreakdown,
    double? totalBudget,
    int? estimatedTime,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fundiName,
    String? fundiImageUrl,
    String? jobTitle,
    String? coverLetter,
    double? proposedBudget,
    String? proposedBudgetType,
    int? estimatedDays,
    Map<String, dynamic>? metadata,
  }) {
    return JobApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      fundiId: fundiId ?? this.fundiId,
      requirements: requirements ?? this.requirements,
      budgetBreakdown: budgetBreakdown ?? this.budgetBreakdown,
      totalBudget: totalBudget ?? this.totalBudget,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fundiName: fundiName ?? this.fundiName,
      fundiImageUrl: fundiImageUrl ?? this.fundiImageUrl,
      jobTitle: jobTitle ?? this.jobTitle,
      coverLetter: coverLetter ?? this.coverLetter,
      proposedBudget: proposedBudget ?? this.proposedBudget,
      proposedBudgetType: proposedBudgetType ?? this.proposedBudgetType,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobApplicationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'JobApplicationModel(id: $id, jobId: $jobId, fundiId: $fundiId, status: $status)';
  }
}

/// Job application status enumeration
enum JobApplicationStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected'),
  withdrawn('withdrawn');

  const JobApplicationStatus(this.value);
  final String value;

  static JobApplicationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return JobApplicationStatus.pending;
      case 'accepted':
        return JobApplicationStatus.accepted;
      case 'rejected':
        return JobApplicationStatus.rejected;
      case 'withdrawn':
        return JobApplicationStatus.withdrawn;
      default:
        throw ArgumentError('Invalid job application status: $value');
    }
  }

  String get displayName {
    switch (this) {
      case JobApplicationStatus.pending:
        return 'Pending';
      case JobApplicationStatus.accepted:
        return 'Accepted';
      case JobApplicationStatus.rejected:
        return 'Rejected';
      case JobApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}
