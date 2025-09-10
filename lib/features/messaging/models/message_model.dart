/// Message model representing chat messages between users
/// Supports text, image, and file messages
class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final MessageType type;
  final String content;
  final String? imageUrl;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final bool isRead;
  final bool isDelivered;
  final DateTime sentAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.content,
    this.imageUrl,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.isRead = false,
    this.isDelivered = false,
    required this.sentAt,
    this.readAt,
    this.metadata,
  });

  /// Check if message is from current user
  bool isFromUser(String userId) => senderId == userId;

  /// Get display file size
  String get displayFileSize {
    if (fileSize == null) return '';

    if (fileSize! < 1024) {
      return '${fileSize!} B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Get message status text
  String get statusText {
    if (isRead) return 'Read';
    if (isDelivered) return 'Delivered';
    return 'Sent';
  }

  /// Get sender name (placeholder - should be resolved from user data)
  String get senderName => 'User $senderId';

  /// Get formatted creation time
  String get createdAtDisplay {
    final now = DateTime.now();
    final difference = now.difference(sentAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Alias for sentAt to match expected property name
  DateTime get createdAt => sentAt;

  /// Create MessageModel from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      type: MessageType.fromString(json['type'] as String),
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as int?,
      isRead: json['is_read'] as bool? ?? false,
      isDelivered: json['is_delivered'] as bool? ?? false,
      sentAt: DateTime.parse(json['sent_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert MessageModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'type': type.value,
      'content': content,
      'image_url': imageUrl,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'is_read': isRead,
      'is_delivered': isDelivered,
      'sent_at': sentAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    MessageType? type,
    String? content,
    String? imageUrl,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    bool? isRead,
    bool? isDelivered,
    DateTime? sentAt,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MessageModel(id: $id, type: $type, content: $content)';
  }
}

/// Message types
enum MessageType {
  text('text'),
  image('image'),
  file('file');

  const MessageType(this.value);
  final String value;

  static MessageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }
}
