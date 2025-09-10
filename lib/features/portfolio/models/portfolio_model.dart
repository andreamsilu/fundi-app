/// Portfolio model representing fundi's work portfolio
/// Contains media files, skills, and work history
class PortfolioModel {
  final String id;
  final String fundiId;
  final String fundiName;
  final String title;
  final String description;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final List<String> skills;
  final String category;
  final String? location;
  final double? budget;
  final String? budgetType;
  final int? durationDays;
  final DateTime completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const PortfolioModel({
    required this.id,
    required this.fundiId,
    required this.fundiName,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.videoUrls,
    required this.skills,
    required this.category,
    this.location,
    this.budget,
    this.budgetType,
    this.durationDays,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Get display budget
  String get displayBudget {
    if (budget == null) return 'Not specified';
    if (budget! >= 1000000) {
      return '${(budget! / 1000000).toStringAsFixed(1)}M ${budgetType ?? ''}';
    } else if (budget! >= 1000) {
      return '${(budget! / 1000).toStringAsFixed(1)}K ${budgetType ?? ''}';
    } else {
      return '${budget!.toStringAsFixed(0)} ${budgetType ?? ''}';
    }
  }

  /// Get duration display
  String get displayDuration {
    if (durationDays == null) return 'Not specified';
    if (durationDays! == 1) return '1 day';
    if (durationDays! < 7) return '$durationDays days';
    if (durationDays! < 30) {
      final weeks = (durationDays! / 7).floor();
      return weeks == 1 ? '1 week' : '$weeks weeks';
    } else {
      final months = (durationDays! / 30).floor();
      return months == 1 ? '1 month' : '$months months';
    }
  }

  /// Get all media URLs
  List<String> get allMediaUrls => [...imageUrls, ...videoUrls];

  /// Check if portfolio has images
  bool get hasImages => imageUrls.isNotEmpty;

  /// Check if portfolio has videos
  bool get hasVideos => videoUrls.isNotEmpty;

  /// Check if portfolio has media
  bool get hasMedia => hasImages || hasVideos;

  /// Get images (alias for imageUrls)
  List<String> get images => imageUrls;

  /// Create PortfolioModel from JSON
  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id'] as String,
      fundiId: json['fundi_id'] as String,
      fundiName: json['fundi_name'] as String? ?? 'Unknown Fundi',
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      videoUrls: List<String>.from(json['video_urls'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      category: json['category'] as String,
      location: json['location'] as String?,
      budget: json['budget'] as double?,
      budgetType: json['budget_type'] as String?,
      durationDays: json['duration_days'] as int?,
      completedAt: DateTime.parse(json['completed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert PortfolioModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fundi_id': fundiId,
      'fundi_name': fundiName,
      'title': title,
      'description': description,
      'image_urls': imageUrls,
      'video_urls': videoUrls,
      'skills': skills,
      'category': category,
      'location': location,
      'budget': budget,
      'budget_type': budgetType,
      'duration_days': durationDays,
      'completed_at': completedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  PortfolioModel copyWith({
    String? id,
    String? fundiId,
    String? fundiName,
    String? title,
    String? description,
    List<String>? imageUrls,
    List<String>? videoUrls,
    List<String>? skills,
    String? category,
    String? location,
    double? budget,
    String? budgetType,
    int? durationDays,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PortfolioModel(
      id: id ?? this.id,
      fundiId: fundiId ?? this.fundiId,
      fundiName: fundiName ?? this.fundiName,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrls: videoUrls ?? this.videoUrls,
      skills: skills ?? this.skills,
      category: category ?? this.category,
      location: location ?? this.location,
      budget: budget ?? this.budget,
      budgetType: budgetType ?? this.budgetType,
      durationDays: durationDays ?? this.durationDays,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    return 'PortfolioModel(id: $id, title: $title, category: $category)';
  }
}

/// Portfolio category enum
enum PortfolioCategory {
  plumbing('plumbing', 'Plumbing'),
  electrical('electrical', 'Electrical'),
  carpentry('carpentry', 'Carpentry'),
  masonry('masonry', 'Masonry'),
  painting('painting', 'Painting'),
  roofing('roofing', 'Roofing'),
  flooring('flooring', 'Flooring'),
  hvac('hvac', 'HVAC'),
  landscaping('landscaping', 'Landscaping'),
  general('general', 'General Construction');

  const PortfolioCategory(this.value, this.displayName);
  final String value;
  final String displayName;

  static PortfolioCategory fromString(String value) {
    for (final category in PortfolioCategory.values) {
      if (category.value == value.toLowerCase()) {
        return category;
      }
    }
    return PortfolioCategory.general;
  }
}
