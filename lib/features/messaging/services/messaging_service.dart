import 'dart:io';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/chat_model.dart' hide MessageModel;
import '../models/message_model.dart';

/// Messaging service for handling chat and message operations
/// Manages real-time messaging between users
class MessagingService {
  final ApiClient _apiClient = ApiClient();

  /// Get all chats for a user
  Future<ChatResult> getChats({int page = 1, int limit = 20}) async {
    try {
      Logger.apiRequest('GET', '/chats');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/chats',
        queryParameters: {'page': page, 'limit': limit},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'GET',
        '/chats',
        response.statusCode,
        response: response.data,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final chats = (data['chats'] as List)
            .map((json) => ChatModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return ChatResult(
          success: true,
          chats: chats,
          totalCount: data['total_count'] as int,
          totalPages: data['total_pages'] as int,
          message: response.message,
        );
      } else {
        return ChatResult(
          success: false,
          chats: [],
          totalCount: 0,
          totalPages: 0,
          message: response.message,
        );
      }
    } catch (e) {
      Logger.apiError('GET', '/chats', e);
      return ChatResult(
        success: false,
        chats: [],
        totalCount: 0,
        totalPages: 0,
        message: 'Failed to load chats',
      );
    }
  }

  /// Get or create a chat between two users
  Future<ChatDetailResult> getOrCreateChat({
    required String participant1Id,
    required String participant2Id,
  }) async {
    try {
      Logger.apiRequest('POST', '/chats');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/chats',
        data: {
          'participant1_id': participant1Id,
          'participant2_id': participant2Id,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'POST',
        '/chats',
        response.statusCode,
        response: response.data,
      );

      if (response.success && response.data != null) {
        final chat = ChatModel.fromJson(response.data!);
        return ChatDetailResult(
          success: true,
          chat: chat,
          message: response.message,
        );
      } else {
        return ChatDetailResult(
          success: false,
          chat: null,
          message: response.message,
        );
      }
    } catch (e) {
      Logger.apiError('POST', '/chats', e);
      return ChatDetailResult(
        success: false,
        chat: null,
        message: 'Failed to create chat',
      );
    }
  }

  /// Get messages for a specific chat
  Future<MessageResult> getMessages({
    required String chatId,
    int page = 1,
    int limit = 50,
    String? beforeMessageId,
  }) async {
    try {
      Logger.apiRequest('GET', '/chats/$chatId/messages');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/chats/$chatId/messages',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (beforeMessageId != null) 'before_message_id': beforeMessageId,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'GET',
        '/chats/$chatId/messages',
        response.statusCode,
        response: response.data,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final messages = (data['messages'] as List)
            .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return MessageResult(
          success: true,
          messages: messages,
          totalCount: data['total_count'] as int,
          totalPages: data['total_pages'] as int,
          message: response.message,
        );
      } else {
        return MessageResult(
          success: false,
          messages: [],
          totalCount: 0,
          totalPages: 0,
          message: response.message,
        );
      }
    } catch (e) {
      Logger.apiError('GET', '/chats/$chatId/messages', e);
      return MessageResult(
        success: false,
        messages: [],
        totalCount: 0,
        totalPages: 0,
        message: 'Failed to load messages',
      );
    }
  }

  /// Send a text message
  Future<MessageDetailResult> sendTextMessage({
    required String chatId,
    required String content,
  }) async {
    try {
      Logger.apiRequest('POST', '/chats/$chatId/messages');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/chats/$chatId/messages',
        data: {'type': 'text', 'content': content},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'POST',
        '/chats/$chatId/messages',
        response.statusCode,
        response: response.data,
      );

      if (response.success && response.data != null) {
        final message = MessageModel.fromJson(response.data!);
        return MessageDetailResult(
          success: true,
          message: message,
          messageText: response.message,
        );
      } else {
        return MessageDetailResult(
          success: false,
          message: null,
          messageText: response.message,
        );
      }
    } catch (e) {
      Logger.apiError('POST', '/chats/$chatId/messages', e);
      return MessageDetailResult(
        success: false,
        message: null,
        messageText: 'Failed to send message',
      );
    }
  }

  /// Send an image message
  Future<MessageDetailResult> sendImageMessage({
    required String chatId,
    required String imageUrl,
    String? caption,
  }) async {
    try {
      Logger.apiRequest('POST', '/chats/$chatId/messages');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/chats/$chatId/messages',
        data: {
          'type': 'image',
          'content': caption ?? '',
          'image_url': imageUrl,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'POST',
        '/chats/$chatId/messages',
        response.statusCode,
        response: response.data,
      );

      if (response.success && response.data != null) {
        final message = MessageModel.fromJson(response.data!);
        return MessageDetailResult(
          success: true,
          message: message,
          messageText: response.message,
        );
      } else {
        return MessageDetailResult(
          success: false,
          message: null,
          messageText: response.message,
        );
      }
    } catch (e) {
      Logger.apiError('POST', '/chats/$chatId/messages', e);
      return MessageDetailResult(
        success: false,
        message: null,
        messageText: 'Failed to send image',
      );
    }
  }

  /// Send a file message
  Future<MessageDetailResult> sendFileMessage({
    required String chatId,
    required String fileUrl,
    required String fileName,
    required int fileSize,
    String? caption,
  }) async {
    try {
      Logger.apiRequest('POST', '/chats/$chatId/messages');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/chats/$chatId/messages',
        data: {
          'type': 'file',
          'content': caption ?? '',
          'file_url': fileUrl,
          'file_name': fileName,
          'file_size': fileSize,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'POST',
        '/chats/$chatId/messages',
        response.statusCode,
        response: response.data,
      );

      if (response.success && response.data != null) {
        final message = MessageModel.fromJson(response.data!);
        return MessageDetailResult(
          success: true,
          message: message,
          messageText: response.message,
        );
      } else {
        return MessageDetailResult(
          success: false,
          message: null,
          messageText: response.message,
        );
      }
    } catch (e) {
      Logger.apiError('POST', '/chats/$chatId/messages', e);
      return MessageDetailResult(
        success: false,
        message: null,
        messageText: 'Failed to send file',
      );
    }
  }

  /// Mark messages as read
  Future<MessageResult> markMessagesAsRead({
    required String chatId,
    required List<String> messageIds,
  }) async {
    try {
      Logger.apiRequest('PUT', '/chats/$chatId/messages/read');

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/chats/$chatId/messages/read',
        data: {'message_ids': messageIds},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'PUT',
        '/chats/$chatId/messages/read',
        response.statusCode,
        response: response.data,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final messages = (data['messages'] as List)
            .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return MessageResult(
          success: true,
          messages: messages,
          totalCount: messages.length,
          totalPages: 1,
          message: response.message,
        );
      } else {
        return MessageResult(
          success: false,
          messages: [],
          totalCount: 0,
          totalPages: 0,
          message: response.message,
        );
      }
    } catch (e) {
      Logger.apiError('PUT', '/chats/$chatId/messages/read', e);
      return MessageResult(
        success: false,
        messages: [],
        totalCount: 0,
        totalPages: 0,
        message: 'Failed to mark messages as read',
      );
    }
  }

  /// Delete a message
  Future<MessageResult> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      Logger.apiRequest('DELETE', '/chats/$chatId/messages/$messageId');

      final response = await _apiClient.delete<Map<String, dynamic>>(
        '/chats/$chatId/messages/$messageId',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'DELETE',
        '/chats/$chatId/messages/$messageId',
        response.statusCode,
        response: response.data,
      );

      return MessageResult(
        success: response.success,
        messages: [],
        totalCount: 0,
        totalPages: 0,
        message: response.message,
      );
    } catch (e) {
      Logger.apiError('DELETE', '/chats/$chatId/messages/$messageId', e);
      return MessageResult(
        success: false,
        messages: [],
        totalCount: 0,
        totalPages: 0,
        message: 'Failed to delete message',
      );
    }
  }

  /// Upload file for messaging
  Future<FileUploadResult> uploadFile({
    required String filePath,
    required String fileName,
    required int fileSize,
  }) async {
    try {
      Logger.apiRequest('POST', '/messages/upload');
      final response = await _apiClient.uploadFile<Map<String, dynamic>>(
        '/messages/upload',
        File(filePath),
        fieldName: 'file',
        additionalData: {'file_name': fileName, 'file_size': fileSize},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      Logger.apiResponse(
        'POST',
        '/messages/upload',
        response.statusCode,
        response: response.data,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        return FileUploadResult(
          success: true,
          fileUrl: data['file_url'] as String,
          fileName: data['file_name'] as String,
          fileSize: data['file_size'] as int,
          message: response.message,
        );
      } else {
        return FileUploadResult(
          success: false,
          fileUrl: '',
          fileName: '',
          fileSize: 0,
          message: response.message,
        );
      }
    } catch (e) {
      Logger.apiError('POST', '/messages/upload', e);
      return FileUploadResult(
        success: false,
        fileUrl: '',
        fileName: '',
        fileSize: 0,
        message: 'Failed to upload file',
      );
    }
  }
}

/// Chat result wrapper
class ChatResult {
  final bool success;
  final List<ChatModel> chats;
  final int totalCount;
  final int totalPages;
  final String message;

  ChatResult({
    required this.success,
    required this.chats,
    required this.totalCount,
    required this.totalPages,
    required this.message,
  });
}

/// Chat detail result wrapper
class ChatDetailResult {
  final bool success;
  final ChatModel? chat;
  final String message;

  ChatDetailResult({
    required this.success,
    required this.chat,
    required this.message,
  });
}

/// Message result wrapper
class MessageResult {
  final bool success;
  final List<MessageModel> messages;
  final int totalCount;
  final int totalPages;
  final String message;

  MessageResult({
    required this.success,
    required this.messages,
    required this.totalCount,
    required this.totalPages,
    required this.message,
  });
}

/// Message detail result wrapper
class MessageDetailResult {
  final bool success;
  final MessageModel? message;
  final String messageText;

  MessageDetailResult({
    required this.success,
    required this.message,
    required this.messageText,
  });
}

/// File upload result wrapper
class FileUploadResult {
  final bool success;
  final String fileUrl;
  final String fileName;
  final int fileSize;
  final String message;

  FileUploadResult({
    required this.success,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
    required this.message,
  });
}
