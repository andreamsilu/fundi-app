/// Portfolio approval model representing a portfolio item awaiting approval
class PortfolioApprovalModel {
  final String id;
  final String fundiId;
  final String fundiName;
  final String fundiEmail;
  final String title;
  final String description;
  final String category;
  final List<String> mediaUrls;
  final List<String> tags;
  final DateTime submittedAt;
  final String status; // pending, approved, rejected
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final Map<String, dynamic> metadata;

  const PortfolioApprovalModel({
    required this.id,
    required this.fundiId,
    required this.fundiName,
    required this.fundiEmail,
    required this.title,
    required this.description,
    required this.category,
    required this.mediaUrls,
    required this.tags,
    required this.submittedAt,
    required this.status,
    this.rejectionReason,
    this.reviewedAt,
    this.reviewedBy,
    required this.metadata,
  });

  /// Create PortfolioApprovalModel from JSON
  factory PortfolioApprovalModel.fromJson(Map<String, dynamic> json) {
    return PortfolioApprovalModel(
      id: json['id'] ?? '',
      fundiId: json['fundiId'] ?? '',
      fundiName: json['fundiName'] ?? '',
      fundiEmail: json['fundiEmail'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      submittedAt: DateTime.parse(
        json['submittedAt'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejectionReason'],
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      reviewedBy: json['reviewedBy'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// Convert PortfolioApprovalModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fundiId': fundiId,
      'fundiName': fundiName,
      'fundiEmail': fundiEmail,
      'title': title,
      'description': description,
      'category': category,
      'mediaUrls': mediaUrls,
      'tags': tags,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status,
      'rejectionReason': rejectionReason,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'metadata': metadata,
    };
  }

  /// Create empty PortfolioApprovalModel
  factory PortfolioApprovalModel.empty() {
    final now = DateTime.now();
    return PortfolioApprovalModel(
      id: '',
      fundiId: '',
      fundiName: '',
      fundiEmail: '',
      title: '',
      description: '',
      category: '',
      mediaUrls: [],
      tags: [],
      submittedAt: now,
      status: 'pending',
      metadata: {},
    );
  }

  /// Copy with new values
  PortfolioApprovalModel copyWith({
    String? id,
    String? fundiId,
    String? fundiName,
    String? fundiEmail,
    String? title,
    String? description,
    String? category,
    List<String>? mediaUrls,
    List<String>? tags,
    DateTime? submittedAt,
    String? status,
    String? rejectionReason,
    DateTime? reviewedAt,
    String? reviewedBy,
    Map<String, dynamic>? metadata,
  }) {
    return PortfolioApprovalModel(
      id: id ?? this.id,
      fundiId: fundiId ?? this.fundiId,
      fundiName: fundiName ?? this.fundiName,
      fundiEmail: fundiEmail ?? this.fundiEmail,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      tags: tags ?? this.tags,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if portfolio item is pending approval
  bool get isPending => status == 'pending';

  /// Check if portfolio item is approved
  bool get isApproved => status == 'approved';

  /// Check if portfolio item is rejected
  bool get isRejected => status == 'rejected';

  /// Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'warning';
      case 'approved':
        return 'success';
      case 'rejected':
        return 'error';
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

  /// Get primary media URL (first image/video)
  String? get primaryMediaUrl {
    return mediaUrls.isNotEmpty ? mediaUrls.first : null;
  }

  /// Check if portfolio has multiple media items
  bool get hasMultipleMedia => mediaUrls.length > 1;
}
