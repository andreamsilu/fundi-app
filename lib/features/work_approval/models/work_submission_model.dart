/// Work submission model representing a work submission awaiting approval
class WorkSubmissionModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String fundiId;
  final String fundiName;
  final String fundiEmail;
  final String title;
  final String description;
  final List<String> mediaUrls;
  final List<String> attachments;
  final DateTime completedAt;
  final DateTime submittedAt;
  final String status; // pending, approved, rejected, needs_revision
  final String? rejectionReason;
  final String? revisionNotes;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final Map<String, dynamic> qualityMetrics;
  final Map<String, dynamic> metadata;

  const WorkSubmissionModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.fundiId,
    required this.fundiName,
    required this.fundiEmail,
    required this.title,
    required this.description,
    required this.mediaUrls,
    required this.attachments,
    required this.completedAt,
    required this.submittedAt,
    required this.status,
    this.rejectionReason,
    this.revisionNotes,
    this.reviewedAt,
    this.reviewedBy,
    required this.qualityMetrics,
    required this.metadata,
  });

  /// Create WorkSubmissionModel from JSON
  factory WorkSubmissionModel.fromJson(Map<String, dynamic> json) {
    return WorkSubmissionModel(
      id: json['id'] ?? '',
      jobId: json['jobId'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      fundiId: json['fundiId'] ?? '',
      fundiName: json['fundiName'] ?? '',
      fundiEmail: json['fundiEmail'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      attachments: List<String>.from(json['attachments'] ?? []),
      completedAt: DateTime.parse(
        json['completedAt'] ?? DateTime.now().toIso8601String(),
      ),
      submittedAt: DateTime.parse(
        json['submittedAt'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejectionReason'],
      revisionNotes: json['revisionNotes'],
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      reviewedBy: json['reviewedBy'],
      qualityMetrics: Map<String, dynamic>.from(json['qualityMetrics'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// Convert WorkSubmissionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'fundiId': fundiId,
      'fundiName': fundiName,
      'fundiEmail': fundiEmail,
      'title': title,
      'description': description,
      'mediaUrls': mediaUrls,
      'attachments': attachments,
      'completedAt': completedAt.toIso8601String(),
      'submittedAt': submittedAt.toIso8601String(),
      'status': status,
      'rejectionReason': rejectionReason,
      'revisionNotes': revisionNotes,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'qualityMetrics': qualityMetrics,
      'metadata': metadata,
    };
  }

  /// Create empty WorkSubmissionModel
  factory WorkSubmissionModel.empty() {
    final now = DateTime.now();
    return WorkSubmissionModel(
      id: '',
      jobId: '',
      jobTitle: '',
      fundiId: '',
      fundiName: '',
      fundiEmail: '',
      title: '',
      description: '',
      mediaUrls: [],
      attachments: [],
      completedAt: now,
      submittedAt: now,
      status: 'pending',
      qualityMetrics: {},
      metadata: {},
    );
  }

  /// Copy with new values
  WorkSubmissionModel copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? fundiId,
    String? fundiName,
    String? fundiEmail,
    String? title,
    String? description,
    List<String>? mediaUrls,
    List<String>? attachments,
    DateTime? completedAt,
    DateTime? submittedAt,
    String? status,
    String? rejectionReason,
    String? revisionNotes,
    DateTime? reviewedAt,
    String? reviewedBy,
    Map<String, dynamic>? qualityMetrics,
    Map<String, dynamic>? metadata,
  }) {
    return WorkSubmissionModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      fundiId: fundiId ?? this.fundiId,
      fundiName: fundiName ?? this.fundiName,
      fundiEmail: fundiEmail ?? this.fundiEmail,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      attachments: attachments ?? this.attachments,
      completedAt: completedAt ?? this.completedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      revisionNotes: revisionNotes ?? this.revisionNotes,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      qualityMetrics: qualityMetrics ?? this.qualityMetrics,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if submission is pending approval
  bool get isPending => status == 'pending';

  /// Check if submission is approved
  bool get isApproved => status == 'approved';

  /// Check if submission is rejected
  bool get isRejected => status == 'rejected';

  /// Check if submission needs revision
  bool get needsRevision => status == 'needs_revision';

  /// Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'warning';
      case 'approved':
        return 'success';
      case 'rejected':
        return 'error';
      case 'needs_revision':
        return 'info';
      default:
        return 'warning';
    }
  }

  /// Get formatted submission date
  String get formattedSubmittedAt {
    final now = DateTime.now();
    final difference = now.difference(submittedAt);

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

  /// Get formatted completion date
  String get formattedCompletedAt {
    final now = DateTime.now();
    final difference = now.difference(completedAt);

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

  /// Get primary media URL (first image/video)
  String? get primaryMediaUrl {
    return mediaUrls.isNotEmpty ? mediaUrls.first : null;
  }

  /// Check if submission has multiple media items
  bool get hasMultipleMedia => mediaUrls.length > 1;

  /// Get quality score from metrics
  double get qualityScore {
    return (qualityMetrics['score'] ?? 0.0).toDouble();
  }

  /// Check if submission has attachments
  bool get hasAttachments => attachments.isNotEmpty;
}
