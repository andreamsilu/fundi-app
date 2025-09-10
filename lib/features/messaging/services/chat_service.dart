import '../../../core/network/api_client.dart';
import '../models/chat_model.dart';
import '../../../core/utils/logger.dart';

/// Chat service for managing chat conversations and messages
/// Handles all chat-related API operations
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Get all chat conversations for the current user
  Future<ChatListResult> getChats() async {
    try {
      Logger.userAction('Fetch chat conversations');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/chats',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final chats = (response.data!['chats'] as List<dynamic>)
            .map((chat) => ChatModel.fromJson(chat as Map<String, dynamic>))
            .toList();

        Logger.userAction('Chat conversations loaded successfully');

        return ChatListResult.success(chats: chats, message: response.message);
      } else {
        Logger.warning('Chat conversations fetch failed: ${response.message}');
        return ChatListResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Chat conversations API error', error: e);
      return ChatListResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Chat conversations unexpected error', error: e);
      return ChatListResult.failure(
        message: 'Failed to load chat conversations',
      );
    }
  }

  /// Get messages for a specific chat
  Future<MessageListResult> getMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      Logger.userAction('Fetch chat messages', data: {'chatId': chatId});

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/chats/$chatId/messages',
        queryParameters: {'page': page, 'limit': limit},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final messages = (response.data!['messages'] as List<dynamic>)
            .map(
              (message) =>
                  MessageModel.fromJson(message as Map<String, dynamic>),
            )
            .toList();

        return MessageListResult.success(
          messages: messages,
          message: response.message,
        );
      } else {
        return MessageListResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Chat messages API error', error: e);
      return MessageListResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Chat messages unexpected error', error: e);
      return MessageListResult.failure(message: 'Failed to load chat messages');
    }
  }

  /// Send a message to a chat
  Future<MessageResult> sendMessage(
    String chatId,
    String content, {
    String? messageType,
  }) async {
    try {
      Logger.userAction(
        'Send message',
        data: {'chatId': chatId, 'type': messageType},
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/chats/$chatId/messages',
        data: {'content': content, 'type': messageType ?? 'text'},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final message = MessageModel.fromJson(response.data!);

        Logger.userAction(
          'Message sent successfully',
          data: {'messageId': message.id},
        );

        return MessageResult.success(
          message: message,
          messageText: response.message,
        );
      } else {
        Logger.warning('Message send failed: ${response.message}');
        return MessageResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Send message API error', error: e);
      return MessageResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Send message unexpected error', error: e);
      return MessageResult.failure(message: 'Failed to send message');
    }
  }

  /// Mark messages as read
  Future<ApiResponse> markAsRead(String chatId, List<String> messageIds) async {
    try {
      Logger.userAction(
        'Mark messages as read',
        data: {'chatId': chatId, 'count': messageIds.length},
      );

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/chats/$chatId/messages/read',
        data: {'message_ids': messageIds},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success) {
        Logger.userAction('Messages marked as read successfully');
      }

      return response;
    } on ApiError catch (e) {
      Logger.error('Mark as read API error', error: e);
      return ApiResponse(
        success: false,
        message: e.message,
        data: null,
        statusCode: 500,
      );
    } catch (e) {
      Logger.error('Mark as read unexpected error', error: e);
      return ApiResponse(
        success: false,
        message: 'Failed to mark messages as read',
        data: null,
        statusCode: 500,
      );
    }
  }

  /// Create a new chat conversation
  Future<ChatResult> createChat(String otherUserId) async {
    try {
      Logger.userAction('Create chat', data: {'otherUserId': otherUserId});

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/chats',
        data: {'other_user_id': otherUserId},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final chat = ChatModel.fromJson(response.data!);

        Logger.userAction(
          'Chat created successfully',
          data: {'chatId': chat.id},
        );

        return ChatResult.success(chat: chat, message: response.message);
      } else {
        Logger.warning('Chat creation failed: ${response.message}');
        return ChatResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Create chat API error', error: e);
      return ChatResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Create chat unexpected error', error: e);
      return ChatResult.failure(message: 'Failed to create chat');
    }
  }
}

/// Chat list result wrapper
class ChatListResult {
  final bool success;
  final String? message;
  final List<ChatModel>? chats;

  ChatListResult._({required this.success, this.message, this.chats});

  factory ChatListResult.success({
    required List<ChatModel> chats,
    String? message,
  }) {
    return ChatListResult._(success: true, chats: chats, message: message);
  }

  factory ChatListResult.failure({required String message}) {
    return ChatListResult._(success: false, message: message);
  }
}

/// Message list result wrapper
class MessageListResult {
  final bool success;
  final String? message;
  final List<MessageModel>? messages;

  MessageListResult._({required this.success, this.message, this.messages});

  factory MessageListResult.success({
    required List<MessageModel> messages,
    String? message,
  }) {
    return MessageListResult._(
      success: true,
      messages: messages,
      message: message,
    );
  }

  factory MessageListResult.failure({required String message}) {
    return MessageListResult._(success: false, message: message);
  }
}

/// Message result wrapper
class MessageResult {
  final bool success;
  final String? message;
  final MessageModel? messageModel;

  MessageResult._({required this.success, this.message, this.messageModel});

  factory MessageResult.success({
    required MessageModel message,
    String? messageText,
  }) {
    return MessageResult._(
      success: true,
      messageModel: message,
      message: messageText,
    );
  }

  factory MessageResult.failure({required String message}) {
    return MessageResult._(success: false, message: message);
  }
}

/// Chat result wrapper
class ChatResult {
  final bool success;
  final String? message;
  final ChatModel? chat;

  ChatResult._({required this.success, this.message, this.chat});

  factory ChatResult.success({required ChatModel chat, String? message}) {
    return ChatResult._(success: true, chat: chat, message: message);
  }

  factory ChatResult.failure({required String message}) {
    return ChatResult._(success: false, message: message);
  }
}
