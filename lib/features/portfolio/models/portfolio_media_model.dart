/// PortfolioMedia model representing portfolio media files
/// This model follows the API structure exactly
class PortfolioMediaModel {
  final String id;
  final String portfolioId;
  final String mediaType;
  final String filePath;
  final int orderIndex;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Additional fields for UI/UX (not in API but needed for mobile)
  final String? fileUrl;
  final String? thumbnailUrl;
  final int? fileSize;
  final String? fileName;
  final Map<String, dynamic>? metadata;

  const PortfolioMediaModel({
    required this.id,
    required this.portfolioId,
    required this.mediaType,
    required this.filePath,
    required this.orderIndex,
    this.createdAt,
    this.updatedAt,
    this.fileUrl,
    this.thumbnailUrl,
    this.fileSize,
    this.fileName,
    this.metadata,
  });

  /// Check if media is an image
  bool get isImage => mediaType == 'image';

  /// Check if media is a video
  bool get isVideo => mediaType == 'video';

  /// Check if media is a document
  bool get isDocument => mediaType == 'document';

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown size';
    
    if (fileSize! < 1024) {
      return '${fileSize!} B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Get file extension
  String get fileExtension {
    if (fileName == null) return '';
    final parts = fileName!.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Create PortfolioMediaModel from JSON (follows API structure)
  factory PortfolioMediaModel.fromJson(Map<String, dynamic> json) {
    return PortfolioMediaModel(
      id: json['id'] as String,
      portfolioId: json['portfolio_id'] as String,
      mediaType: json['media_type'] as String,
      filePath: json['file_path'] as String,
      orderIndex: json['order_index'] as int,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      fileUrl: json['file_url'] as String?, // Additional field for mobile
      thumbnailUrl: json['thumbnail_url'] as String?, // Additional field for mobile
      fileSize: json['file_size'] as int?, // Additional field for mobile
      fileName: json['file_name'] as String?, // Additional field for mobile
      metadata: json['metadata'] as Map<String, dynamic>?, // Additional field for mobile
    );
  }

  /// Convert PortfolioMediaModel to JSON (follows API structure)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'portfolio_id': portfolioId,
      'media_type': mediaType,
      'file_path': filePath,
      'order_index': orderIndex,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'file_url': fileUrl, // Additional field for mobile
      'thumbnail_url': thumbnailUrl, // Additional field for mobile
      'file_size': fileSize, // Additional field for mobile
      'file_name': fileName, // Additional field for mobile
      'metadata': metadata, // Additional field for mobile
    };
  }

  /// Create a copy with updated fields
  PortfolioMediaModel copyWith({
    String? id,
    String? portfolioId,
    String? mediaType,
    String? filePath,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fileUrl,
    String? thumbnailUrl,
    int? fileSize,
    String? fileName,
    Map<String, dynamic>? metadata,
  }) {
    return PortfolioMediaModel(
      id: id ?? this.id,
      portfolioId: portfolioId ?? this.portfolioId,
      mediaType: mediaType ?? this.mediaType,
      filePath: filePath ?? this.filePath,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileSize: fileSize ?? this.fileSize,
      fileName: fileName ?? this.fileName,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortfolioMediaModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PortfolioMediaModel(id: $id, portfolioId: $portfolioId, mediaType: $mediaType, filePath: $filePath)';
  }
}
