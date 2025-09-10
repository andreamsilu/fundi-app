import 'package:flutter/material.dart';

/// Chat model representing a conversation between users
class ChatModel {
  final String id;
  final String participantName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isRead;
  final String? imageUrl;

  const ChatModel({
    required this.id,
    required this.participantName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isRead = false,
    this.imageUrl,
  });

  /// Get the other participant's name (for display purposes)
  String get otherParticipantName => participantName;

  /// Get formatted last message time
  String get lastMessageTimeDisplay {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime);

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

  /// Create a copy with updated values
  ChatModel copyWith({
    String? id,
    String? participantName,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isRead,
    String? imageUrl,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participantName: participantName ?? this.participantName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantName': participantName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  /// Create from JSON
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      participantName: json['participantName'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime:
          DateTime.tryParse(json['lastMessageTime'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
      imageUrl: json['imageUrl'],
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
    return 'ChatModel(id: $id, participantName: $participantName, lastMessage: $lastMessage)';
  }
}
