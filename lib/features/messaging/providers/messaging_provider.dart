import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/messaging_service.dart';
import '../../../core/utils/logger.dart';

/// Messaging provider for state management
/// Handles chat and message-related state and operations
class MessagingProvider extends ChangeNotifier {
  final MessagingService _messagingService = MessagingService();

  List<ChatModel> _chats = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  String? _currentChatId;

  /// Get chats list
  List<ChatModel> get chats => _chats;

  /// Get messages list
  List<MessageModel> get messages => _messages;

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Check if loading more
  bool get isLoadingMore => _isLoadingMore;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Get current page
  int get currentPage => _currentPage;

  /// Get total pages
  int get totalPages => _totalPages;

  /// Get current chat ID
  String? get currentChatId => _currentChatId;

  /// Load chats
  Future<void> loadChats({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _chats.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _messagingService.getChats(page: _currentPage);

      if (result.success) {
        if (refresh) {
          _chats = result.chats;
        } else {
          _chats.addAll(result.chats);
        }
        _totalPages = result.totalPages;

        Logger.info(
          'Chats loaded successfully',
          data: {'count': result.chats.length, 'total': result.totalCount},
        );
      } else {
        _setError(result.message);
      }
    } catch (e) {
      Logger.error('Load chats error', error: e);
      _setError('Failed to load chats');
    } finally {
      _setLoading(false);
    }
  }

  /// Load more chats (pagination)
  Future<void> loadMoreChats() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    _setLoadingMore(true);

    try {
      _currentPage++;
      final result = await _messagingService.getChats(page: _currentPage);

      if (result.success) {
        _chats.addAll(result.chats);
        Logger.info('More chats loaded', data: {'count': result.chats.length});
      } else {
        _currentPage--; // Revert page increment on error
        _setError(result.message);
      }
    } catch (e) {
      Logger.error('Load more chats error', error: e);
      _currentPage--; // Revert page increment on error
      _setError('Failed to load more chats');
    } finally {
      _setLoadingMore(false);
    }
  }

  /// Get or create a chat between two users
  Future<ChatModel?> getOrCreateChat({
    required String participant1Id,
    required String participant2Id,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _messagingService.getOrCreateChat(
        participant1Id: participant1Id,
        participant2Id: participant2Id,
      );

      if (result.success && result.chat != null) {
        // Add to chats list if not already present
        final existingIndex = _chats.indexWhere(
          (chat) => chat.id == result.chat!.id,
        );
        if (existingIndex == -1) {
          _chats.insert(0, result.chat!);
          notifyListeners();
        }
        Logger.info(
          'Chat created/retrieved successfully',
          data: {'chatId': result.chat!.id},
        );
        return result.chat;
      } else {
        _setError(result.message);
        return null;
      }
    } catch (e) {
      Logger.error('Get or create chat error', error: e);
      _setError('Failed to create chat');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Load messages for a specific chat
  Future<void> loadMessages({
    required String chatId,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _messages.clear();
    }

    _setLoading(true);
    _clearError();
    _currentChatId = chatId;

    try {
      final result = await _messagingService.getMessages(
        chatId: chatId,
        page: _currentPage,
      );

      if (result.success) {
        if (refresh) {
          _messages = result.messages;
        } else {
          _messages.addAll(result.messages);
        }
        _totalPages = result.totalPages;

        Logger.info(
          'Messages loaded successfully',
          data: {'count': result.messages.length, 'total': result.totalCount},
        );
      } else {
        _setError(result.message);
      }
    } catch (e) {
      Logger.error('Load messages error', error: e);
      _setError('Failed to load messages');
    } finally {
      _setLoading(false);
    }
  }

  /// Load more messages (pagination)
  Future<void> loadMoreMessages() async {
    if (_isLoadingMore || _currentPage >= _totalPages || _currentChatId == null) {
      return;
    }

    _setLoadingMore(true);

    try {
      _currentPage++;
      final result = await _messagingService.getMessages(
        chatId: _currentChatId!,
        page: _currentPage,
      );

      if (result.success) {
        _messages.addAll(result.messages);
        Logger.info(
          'More messages loaded',
          data: {'count': result.messages.length},
        );
      } else {
        _currentPage--; // Revert page increment on error
        _setError(result.message);
      }
    } catch (e) {
      Logger.error('Load more messages error', error: e);
      _currentPage--; // Revert page increment on error
      _setError('Failed to load more messages');
    } finally {
      _setLoadingMore(false);
    }
  }

  /// Send a text message
  Future<bool> sendTextMessage({
    required String chatId,
    required String content,
  }) async {
    try {
      final result = await _messagingService.sendTextMessage(
        chatId: chatId,
        content: content,
      );

      if (result.success && result.message != null) {
        _messages.add(result.message!);
        notifyListeners();
        Logger.info(
          'Text message sent successfully',
          data: {'messageId': result.message!.id},
        );
        return true;
      } else {
        _setError(result.messageText);
        return false;
      }
    } catch (e) {
      Logger.error('Send text message error', error: e);
      _setError('Failed to send message');
      return false;
    }
  }

  /// Send an image message
  Future<bool> sendImageMessage({
    required String chatId,
    required String imageUrl,
    String? caption,
  }) async {
    try {
      final result = await _messagingService.sendImageMessage(
        chatId: chatId,
        imageUrl: imageUrl,
        caption: caption,
      );

      if (result.success && result.message != null) {
        _messages.add(result.message!);
        notifyListeners();
        Logger.info(
          'Image message sent successfully',
          data: {'messageId': result.message!.id},
        );
        return true;
      } else {
        _setError(result.messageText);
        return false;
      }
    } catch (e) {
      Logger.error('Send image message error', error: e);
      _setError('Failed to send image');
      return false;
    }
  }

  /// Send a file message
  Future<bool> sendFileMessage({
    required String chatId,
    required String fileUrl,
    required String fileName,
    required int fileSize,
    String? caption,
  }) async {
    try {
      final result = await _messagingService.sendFileMessage(
        chatId: chatId,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
        caption: caption,
      );

      if (result.success && result.message != null) {
        _messages.add(result.message!);
        notifyListeners();
        Logger.info(
          'File message sent successfully',
          data: {'messageId': result.message!.id},
        );
        return true;
      } else {
        _setError(result.messageText);
        return false;
      }
    } catch (e) {
      Logger.error('Send file message error', error: e);
      _setError('Failed to send file');
      return false;
    }
  }

  /// Mark messages as read
  Future<bool> markMessagesAsRead({
    required String chatId,
    required List<String> messageIds,
  }) async {
    try {
      final result = await _messagingService.markMessagesAsRead(
        chatId: chatId,
        messageIds: messageIds,
      );

      if (result.success) {
        // Update message read status in local list
        for (final messageId in messageIds) {
          final index = _messages.indexWhere((msg) => msg.id == messageId);
          if (index != -1) {
            _messages[index] = _messages[index].copyWith(
              isRead: true,
              readAt: DateTime.now(),
            );
          }
        }
        notifyListeners();
        Logger.info(
          'Messages marked as read',
          data: {'count': messageIds.length},
        );
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Mark messages as read error', error: e);
      _setError('Failed to mark messages as read');
      return false;
    }
  }

  /// Delete a message
  Future<bool> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      final result = await _messagingService.deleteMessage(
        chatId: chatId,
        messageId: messageId,
      );

      if (result.success) {
        _messages.removeWhere((msg) => msg.id == messageId);
        notifyListeners();
        Logger.info(
          'Message deleted successfully',
          data: {'messageId': messageId},
        );
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      Logger.error('Delete message error', error: e);
      _setError('Failed to delete message');
      return false;
    }
  }

  /// Upload file for messaging
  Future<String?> uploadFile({
    required String filePath,
    required String fileName,
    required int fileSize,
  }) async {
    try {
      final result = await _messagingService.uploadFile(
        filePath: filePath,
        fileName: fileName,
        fileSize: fileSize,
      );

      if (result.success) {
        Logger.info('File uploaded successfully', data: {'fileName': fileName});
        return result.fileUrl;
      } else {
        _setError(result.message);
        return null;
      }
    } catch (e) {
      Logger.error('Upload file error', error: e);
      _setError('Failed to upload file');
      return null;
    }
  }

  /// Clear current chat
  void clearCurrentChat() {
    _currentChatId = null;
    _messages.clear();
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set loading more state
  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error manually
  void clearError() {
    _clearError();
  }
}
