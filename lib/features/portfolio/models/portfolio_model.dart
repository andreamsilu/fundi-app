/// Portfolio model representing fundi portfolio items
/// This model follows the API structure exactly
class PortfolioModel {
  final String id;
  final String fundiId;
  final String title;
  final String description;
  final String category;
  final List<String> skillsUsed;
  final List<String> images;
  final int durationHours;
  final double budget;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional fields for UI/UX (not in API but needed for mobile)
  final String? fundiName;
  final String? fundiImageUrl;
  final List<String>? imageUrls;
  final List<String>? videoUrls;
  final String? location;
  final String? clientName;
  final String? clientImageUrl;
  final Map<String, dynamic>? metadata;

  const PortfolioModel({
    required this.id,
    required this.fundiId,
    required this.title,
    required this.description,
    required this.category,
    required this.skillsUsed,
    required this.images,
    required this.durationHours,
    required this.budget,
    this.createdAt,
    this.updatedAt,
    this.fundiName,
    this.fundiImageUrl,
    this.imageUrls,
    this.videoUrls,
    this.location,
    this.clientName,
    this.clientImageUrl,
    this.metadata,
  });

  /// Get formatted budget
  String get formattedBudget {
    final currency = 'TZS';
    if (budget >= 1000000) {
      return '$currency ${(budget / 1000000).toStringAsFixed(1)}M';
    } else if (budget >= 1000) {
      return '$currency ${(budget / 1000).toStringAsFixed(1)}K';
    } else {
      return '$currency ${budget.toStringAsFixed(0)}';
    }
  }

  /// Get formatted duration
  String get formattedDuration {
    if (durationHours < 24) {
      return '$durationHours hour${durationHours > 1 ? 's' : ''}';
    } else {
      final days = (durationHours / 24).floor();
      final hours = durationHours % 24;
      if (hours > 0) {
        return '$days day${days > 1 ? 's' : ''} $hours hour${hours > 1 ? 's' : ''}';
      } else {
        return '$days day${days > 1 ? 's' : ''}';
      }
    }
  }

  /// Get skills as comma-separated string
  String get skillsString {
    return skillsUsed.join(', ');
  }

  /// Check if portfolio has images
  bool get hasImages => imageUrls != null && imageUrls!.isNotEmpty;

  /// Check if portfolio has videos
  bool get hasVideos => videoUrls != null && videoUrls!.isNotEmpty;

  /// Get formatted created date
  String get formattedCreatedAt {
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

  /// Create PortfolioModel from JSON (follows API structure)
  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle skills_used field - can be string or list
      List<String> skillsUsed = [];
      if (json['skills_used'] != null) {
        if (json['skills_used'] is String) {
          // Handle comma-separated string
          skillsUsed = (json['skills_used'] as String)
              .split(',')
              .map<String>((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        } else if (json['skills_used'] is List) {
          // Convert List<dynamic> to List<String> safely
          skillsUsed = (json['skills_used'] as List<dynamic>)
              .map<String>((e) => e.toString())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }

      // Handle images field - can be null or list
      List<String> images = [];
      if (json['images'] != null && json['images'] is List) {
        // Convert List<dynamic> to List<String> safely
        images = (json['images'] as List<dynamic>)
            .map<String>((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      // Handle media field if present
      List<String> imageUrls = [];
      if (json['media'] != null && json['media'] is List) {
        final mediaList = json['media'] as List<dynamic>;
        for (final media in mediaList) {
          if (media is Map<String, dynamic>) {
            // Try file_url first (from API), then file_path (fallback)
            final fileUrl = media['file_url'] ?? media['file_path'];
            if (fileUrl != null) {
              imageUrls.add(fileUrl.toString());
            }
          }
        }
      }

      return PortfolioModel(
        id: json['id']
            .toString(), // Convert to String to handle both int and String
        fundiId: json['fundi_id']
            .toString(), // Convert to String to handle both int and String
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'General',
        skillsUsed: skillsUsed,
        images: images,
        durationHours: json['duration_hours'] as int? ?? 0,
        budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        fundiName: json['fundi_name'] as String?, // Additional field for mobile
        fundiImageUrl:
            json['fundi_image_url'] as String?, // Additional field for mobile
        imageUrls: imageUrls.isNotEmpty
            ? imageUrls
            : null, // Additional field for mobile
        videoUrls: json['video_urls'] != null
            ? (json['video_urls'] as List)
                  .map<String>((e) => e.toString())
                  .toList()
            : null, // Additional field for mobile
        location: json['location'] as String?, // Additional field for mobile
        clientName:
            json['client_name'] as String?, // Additional field for mobile
        clientImageUrl:
            json['client_image_url'] as String?, // Additional field for mobile
        metadata:
            json['metadata']
                as Map<String, dynamic>?, // Additional field for mobile
      );
    } catch (e) {
      print('Error parsing PortfolioModel: $e');
      // Return empty portfolio model if parsing fails
      return PortfolioModel(
        id: '0',
        fundiId: '0',
        title: 'Error loading portfolio',
        description: 'Failed to load portfolio item',
        category: 'General',
        skillsUsed: [],
        images: [],
        durationHours: 0,
        budget: 0.0,
      );
    }
  }

  /// Convert PortfolioModel to JSON (follows API structure exactly)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fundi_id': fundiId,
      'title': title,
      'description': description,
      'category': category,
      'skills_used': skillsUsed,
      'images': images,
      'duration_hours': durationHours,
      'budget': budget,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  PortfolioModel copyWith({
    String? id,
    String? fundiId,
    String? title,
    String? description,
    String? category,
    List<String>? skillsUsed,
    List<String>? images,
    int? durationHours,
    double? budget,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fundiName,
    String? fundiImageUrl,
    List<String>? imageUrls,
    List<String>? videoUrls,
    String? location,
    String? clientName,
    String? clientImageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return PortfolioModel(
      id: id ?? this.id,
      fundiId: fundiId ?? this.fundiId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      skillsUsed: skillsUsed ?? this.skillsUsed,
      images: images ?? this.images,
      durationHours: durationHours ?? this.durationHours,
      budget: budget ?? this.budget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fundiName: fundiName ?? this.fundiName,
      fundiImageUrl: fundiImageUrl ?? this.fundiImageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrls: videoUrls ?? this.videoUrls,
      location: location ?? this.location,
      clientName: clientName ?? this.clientName,
      clientImageUrl: clientImageUrl ?? this.clientImageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortfolioModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PortfolioModel(id: $id, title: $title, fundiId: $fundiId, budget: $formattedBudget)';
  }
}

/// Portfolio category enumeration - REMOVED
/// All categories now loaded dynamically from API
/// No hardcoded categories allowed
