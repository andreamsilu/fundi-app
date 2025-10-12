import 'dart:io';
import '../network/api_client.dart';
import '../constants/api_endpoints.dart';
import '../utils/logger.dart';

/// Centralized file upload service for all file operations
/// Handles portfolio media, job media, and document uploads
class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Upload portfolio media (image or video)
  Future<FileUploadResult> uploadPortfolioMedia({
    required String portfolioId,
    required File file,
    required String mediaType, // 'image' or 'video'
    int? orderIndex,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      Logger.userAction(
        'Uploading portfolio media',
        data: {'portfolio_id': portfolioId, 'media_type': mediaType},
      );

      final response = await _apiClient.uploadFile<Map<String, dynamic>>(
        ApiEndpoints.uploadPortfolioMedia,
        file,
        fieldName: 'file',
        additionalData: {
          'portfolio_id': portfolioId,
          'media_type': mediaType,
          if (orderIndex != null) 'order_index': orderIndex,
        },
        onSendProgress: onProgress,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        Logger.userAction('Portfolio media uploaded successfully');
        return FileUploadResult.success(
          id: response.data!['id'].toString(),
          fileUrl: response.data!['file_url'] as String,
          filePath: response.data!['file_path'] as String,
          mediaType: mediaType,
        );
      } else {
        Logger.warning('Failed to upload portfolio media: ${response.message}');
        return FileUploadResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Upload portfolio media API error', error: e);
      return FileUploadResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Upload portfolio media unexpected error', error: e);
      return FileUploadResult.failure(message: 'Upload failed: $e');
    }
  }

  /// Upload job media (image or video)
  Future<FileUploadResult> uploadJobMedia({
    required String jobId,
    required File file,
    required String mediaType, // 'image' or 'video'
    int? orderIndex,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      Logger.userAction(
        'Uploading job media',
        data: {'job_id': jobId, 'media_type': mediaType},
      );

      final response = await _apiClient.uploadFile<Map<String, dynamic>>(
        ApiEndpoints.uploadJobMedia,
        file,
        fieldName: 'file',
        additionalData: {
          'job_id': jobId,
          'media_type': mediaType,
          if (orderIndex != null) 'order_index': orderIndex,
        },
        onSendProgress: onProgress,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        Logger.userAction('Job media uploaded successfully');
        return FileUploadResult.success(
          id: response.data!['id'].toString(),
          fileUrl: response.data!['file_url'] as String,
          filePath: response.data!['file_path'] as String,
          mediaType: mediaType,
        );
      } else {
        Logger.warning('Failed to upload job media: ${response.message}');
        return FileUploadResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Upload job media API error', error: e);
      return FileUploadResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Upload job media unexpected error', error: e);
      return FileUploadResult.failure(message: 'Upload failed: $e');
    }
  }

  /// Upload profile document (VETA certificate, ID copy)
  Future<FileUploadResult> uploadProfileDocument({
    required File file,
    required String documentType, // 'veta_certificate', 'id_copy', 'other'
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      Logger.userAction(
        'Uploading profile document',
        data: {'document_type': documentType},
      );

      final response = await _apiClient.uploadFile<Map<String, dynamic>>(
        ApiEndpoints.uploadProfileDocument,
        file,
        fieldName: 'file',
        additionalData: {'document_type': documentType},
        onSendProgress: onProgress,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        Logger.userAction('Profile document uploaded successfully');
        return FileUploadResult.success(
          id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
          fileUrl: response.data!['file_url'] as String,
          filePath: response.data!['file_path'] as String,
          mediaType: documentType,
        );
      } else {
        Logger.warning('Failed to upload document: ${response.message}');
        return FileUploadResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('Upload document API error', error: e);
      return FileUploadResult.failure(message: e.message);
    } catch (e) {
      Logger.error('Upload document unexpected error', error: e);
      return FileUploadResult.failure(message: 'Upload failed: $e');
    }
  }

  /// Upload multiple files sequentially
  Future<List<FileUploadResult>> uploadMultipleFiles({
    required List<File> files,
    required String endpoint,
    required Map<String, dynamic> Function(int index) additionalDataBuilder,
    Function(int fileIndex, int sent, int total)? onProgress,
  }) async {
    final results = <FileUploadResult>[];

    for (var i = 0; i < files.length; i++) {
      try {
        final response = await _apiClient.uploadFile<Map<String, dynamic>>(
          endpoint,
          files[i],
          fieldName: 'file',
          additionalData: additionalDataBuilder(i),
          onSendProgress: onProgress != null
              ? (sent, total) => onProgress(i, sent, total)
              : null,
          fromJson: (data) => data as Map<String, dynamic>,
        );

        if (response.success && response.data != null) {
          results.add(
            FileUploadResult.success(
              id: response.data!['id'].toString(),
              fileUrl: response.data!['file_url'] as String,
              filePath: response.data!['file_path'] as String,
              mediaType: response.data!['media_type'] as String,
            ),
          );
        } else {
          results.add(FileUploadResult.failure(message: response.message));
        }
      } catch (e) {
        results.add(FileUploadResult.failure(message: 'Upload failed: $e'));
      }
    }

    return results;
  }

  /// Delete media file by ID
  Future<bool> deleteMedia(String mediaId) async {
    try {
      Logger.userAction('Deleting media', data: {'media_id': mediaId});

      final response = await _apiClient.delete(
        ApiEndpoints.getDeleteMediaEndpoint(mediaId),
      );

      if (response.success) {
        Logger.userAction('Media deleted successfully');
        return true;
      } else {
        Logger.warning('Failed to delete media: ${response.message}');
        return false;
      }
    } catch (e) {
      Logger.error('Delete media error', error: e);
      return false;
    }
  }

  /// Get media URL by ID
  Future<String?> getMediaUrl(String mediaId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getMediaUrlEndpoint(mediaId),
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!['file_url'] as String?;
      }
      return null;
    } catch (e) {
      Logger.error('Get media URL error', error: e);
      return null;
    }
  }
}

/// File upload result wrapper
class FileUploadResult {
  final bool success;
  final String? id;
  final String? fileUrl;
  final String? filePath;
  final String? mediaType;
  final String message;

  FileUploadResult._({
    required this.success,
    this.id,
    this.fileUrl,
    this.filePath,
    this.mediaType,
    required this.message,
  });

  factory FileUploadResult.success({
    required String id,
    required String fileUrl,
    required String filePath,
    required String mediaType,
  }) {
    return FileUploadResult._(
      success: true,
      id: id,
      fileUrl: fileUrl,
      filePath: filePath,
      mediaType: mediaType,
      message: 'Upload successful',
    );
  }

  factory FileUploadResult.failure({required String message}) {
    return FileUploadResult._(success: false, message: message);
  }
}


