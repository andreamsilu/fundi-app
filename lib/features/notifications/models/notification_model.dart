/// Notification model representing user notifications
/// This model follows the API structure exactly
class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final bool readStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Additional fields for UI/UX (not in API but needed for mobile)
  final String? senderName;
  final String? senderImageUrl;
  final String? actionUrl;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.readStatus,
    this.createdAt,
    this.updatedAt,
    this.senderName,
    this.senderImageUrl,
    this.actionUrl,
    this.data,
    this.metadata,
  });

  /// Check if notification is read
  bool get isRead => readStatus;

  /// Check if notification is unread
  bool get isUnread => !readStatus;

  /// Get notification type display name
  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'job_application':
        return 'Job Application';
      case 'job_approved':
        return 'Job Approved';
      case 'job_rejected':
        return 'Job Rejected';
      case 'payment_received':
        return 'Payment Received';
      case 'rating_received':
        return 'Rating Received';
      case 'message_received':
        return 'Message Received';
      case 'system':
        return 'System Notification';
      default:
        return type.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
        ).join(' ');
    }
  }

  /// Get notification type name (alias for type)
  String get name => type;

  /// Get notification icon based on type
  String get iconName {
    switch (type.toLowerCase()) {
      case 'job_application':
        return 'work';
      case 'job_approved':
        return 'check_circle';
      case 'job_rejected':
        return 'cancel';
      case 'payment_received':
        return 'payment';
      case 'rating_received':
        return 'star';
      case 'message_received':
        return 'message';
      case 'system':
        return 'info';
      default:
        return 'notifications';
    }
  }

  /// Get formatted time
  String get formattedTime {
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

  /// Get short message preview
  String get messagePreview {
    if (message.length <= 100) return message;
    return '${message.substring(0, 100)}...';
  }

  /// Create NotificationModel from JSON (follows API structure)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      readStatus: json['read_status'] as bool,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      senderName: json['sender_name'] as String?, // Additional field for mobile
      senderImageUrl: json['sender_image_url'] as String?, // Additional field for mobile
      actionUrl: json['action_url'] as String?, // Additional field for mobile
      data: json['data'] as Map<String, dynamic>?, // Additional field for mobile
      metadata: json['metadata'] as Map<String, dynamic>?, // Additional field for mobile
    );
  }

  /// Convert NotificationModel to JSON (follows API structure exactly)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'read_status': readStatus,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    bool? readStatus,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? senderName,
    String? senderImageUrl,
    String? actionUrl,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      readStatus: isRead ?? readStatus ?? this.readStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      senderName: senderName ?? this.senderName,
      senderImageUrl: senderImageUrl ?? this.senderImageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      data: data ?? this.data,
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
    return 'NotificationModel(id: $id, type: $type, title: $title, readStatus: $readStatus)';
  }
}

/// Notification result wrapper
class NotificationResult {
  final bool success;
  final List<NotificationModel> notifications;
  final int totalCount;
  final int unreadCount;
  final int currentPage;
  final int totalPages;
  final String? message;

  const NotificationResult({
    required this.success,
    required this.notifications,
    required this.totalCount,
    required this.unreadCount,
    required this.currentPage,
    required this.totalPages,
    this.message,
  });

  factory NotificationResult.success({
    required List<NotificationModel> notifications,
    required int totalCount,
    required int unreadCount,
    required int currentPage,
    required int totalPages,
    String? message,
  }) {
    return NotificationResult(
      success: true,
      notifications: notifications,
      totalCount: totalCount,
      unreadCount: unreadCount,
      currentPage: currentPage,
      totalPages: totalPages,
      message: message,
    );
  }

  factory NotificationResult.failure({
    required String message,
  }) {
    return NotificationResult(
      success: false,
      notifications: [],
      totalCount: 0,
      unreadCount: 0,
      currentPage: 0,
      totalPages: 0,
      message: message,
    );
  }
}

/// Service result wrapper
class ServiceResult {
  final bool success;
  final String? message;

  const ServiceResult({
    required this.success,
    this.message,
  });

  factory ServiceResult.success({String? message}) {
    return ServiceResult(success: true, message: message);
  }

  factory ServiceResult.failure({required String message}) {
    return ServiceResult(success: false, message: message);
  }
}