/// Notification model representing app notifications
/// Supports different notification types and actions
class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final bool isRead;
  final bool isActionable;
  final String? actionText;
  final String? actionUrl;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.imageUrl,
    this.data,
    this.isRead = false,
    this.isActionable = false,
    this.actionText,
    this.actionUrl,
    required this.createdAt,
    this.readAt,
    this.metadata,
  });

  /// Get time ago text
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  /// Get notification icon
  String get icon {
    switch (type) {
      case NotificationType.jobApplication:
        return '💼';
      case NotificationType.jobAccepted:
        return '✅';
      case NotificationType.jobRejected:
        return '❌';
      case NotificationType.jobCompleted:
        return '🎉';
      case NotificationType.message:
        return '💬';
      case NotificationType.payment:
        return '💰';
      case NotificationType.verification:
        return '🔐';
      case NotificationType.system:
        return '🔔';
      case NotificationType.promotion:
        return '🎯';
    }
  }

  /// Get notification color
  String get color {
    switch (type) {
      case NotificationType.jobApplication:
        return 'blue';
      case NotificationType.jobAccepted:
        return 'green';
      case NotificationType.jobRejected:
        return 'red';
      case NotificationType.jobCompleted:
        return 'green';
      case NotificationType.message:
        return 'blue';
      case NotificationType.payment:
        return 'green';
      case NotificationType.verification:
        return 'orange';
      case NotificationType.system:
        return 'gray';
      case NotificationType.promotion:
        return 'purple';
    }
  }

  /// Create NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.fromString(json['type'] as String),
      title: json['title'] as String,
      message: json['message'] as String,
      imageUrl: json['image_url'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      isActionable: json['is_actionable'] as bool? ?? false,
      actionText: json['action_text'] as String?,
      actionUrl: json['action_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert NotificationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.value,
      'title': title,
      'message': message,
      'image_url': imageUrl,
      'data': data,
      'is_read': isRead,
      'is_actionable': isActionable,
      'action_text': actionText,
      'action_url': actionUrl,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    String? imageUrl,
    Map<String, dynamic>? data,
    bool? isRead,
    bool? isActionable,
    String? actionText,
    String? actionUrl,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      isActionable: isActionable ?? this.isActionable,
      actionText: actionText ?? this.actionText,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: $type, title: $title)';
  }
}

/// Notification types
enum NotificationType {
  jobApplication('job_application'),
  jobAccepted('job_accepted'),
  jobRejected('job_rejected'),
  jobCompleted('job_completed'),
  message('message'),
  payment('payment'),
  verification('verification'),
  system('system'),
  promotion('promotion');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'job_application':
        return NotificationType.jobApplication;
      case 'job_accepted':
        return NotificationType.jobAccepted;
      case 'job_rejected':
        return NotificationType.jobRejected;
      case 'job_completed':
        return NotificationType.jobCompleted;
      case 'message':
        return NotificationType.message;
      case 'payment':
        return NotificationType.payment;
      case 'verification':
        return NotificationType.verification;
      case 'system':
        return NotificationType.system;
      case 'promotion':
        return NotificationType.promotion;
      default:
        return NotificationType.system;
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.jobApplication:
        return 'Job Application';
      case NotificationType.jobAccepted:
        return 'Job Accepted';
      case NotificationType.jobRejected:
        return 'Job Rejected';
      case NotificationType.jobCompleted:
        return 'Job Completed';
      case NotificationType.message:
        return 'Message';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.verification:
        return 'Verification';
      case NotificationType.system:
        return 'System';
      case NotificationType.promotion:
        return 'Promotion';
    }
  }
}

