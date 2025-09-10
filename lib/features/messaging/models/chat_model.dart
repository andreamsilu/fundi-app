/// User model for chat participants
class ChatUser {
  final String id;
  final String name;
  final String? profileImageUrl;

  const ChatUser({required this.id, required this.name, this.profileImageUrl});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profileImageUrl: json['profile_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'profile_image_url': profileImageUrl};
  }
}

/// Message model for chat messages
class MessageModel {
  final String id;
  final String content;
  final String senderId;
  final DateTime timestamp;
  final String type;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    this.type = 'text',
    this.isRead = false,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      senderId: json['sender_id'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      type: json['type'] ?? 'text',
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender_id': senderId,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'is_read': isRead,
    };
  }
}

/// Chat model representing a conversation between users
class ChatModel {
  final String id;
  final ChatUser otherUser;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  const ChatModel({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  /// Get the other participant's name (for display purposes)
  String get otherParticipantName => otherUser.name;

  /// Create a copy with updated values
  ChatModel copyWith({
    String? id,
    ChatUser? otherUser,
    MessageModel? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      otherUser: otherUser ?? this.otherUser,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'other_user': otherUser.toJson(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      otherUser: ChatUser.fromJson(json['other_user'] ?? {}),
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatModel(id: $id, otherUser: $otherUser, lastMessage: $lastMessage)';
  }
}
