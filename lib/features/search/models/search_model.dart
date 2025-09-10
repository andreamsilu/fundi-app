/// Search filters model for job and fundi search
/// Provides comprehensive filtering options
class SearchFilters {
  final String? query;
  final String? category;
  final String? location;
  final double? minBudget;
  final double? maxBudget;
  final String? budgetType;
  final List<String> skills;
  final double? minRating;
  final bool? isVerified;
  final String? sortBy;
  final String? sortOrder;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final double? latitude;
  final double? longitude;
  final double? radius; // in kilometers
  final Map<String, dynamic>? customFilters;

  const SearchFilters({
    this.query,
    this.category,
    this.location,
    this.minBudget,
    this.maxBudget,
    this.budgetType,
    this.skills = const [],
    this.minRating,
    this.isVerified,
    this.sortBy,
    this.sortOrder,
    this.dateFrom,
    this.dateTo,
    this.latitude,
    this.longitude,
    this.radius,
    this.customFilters,
  });

  /// Check if any filters are applied
  bool get hasFilters {
    return query != null ||
        category != null ||
        location != null ||
        minBudget != null ||
        maxBudget != null ||
        budgetType != null ||
        skills.isNotEmpty ||
        minRating != null ||
        isVerified != null ||
        sortBy != null ||
        dateFrom != null ||
        dateTo != null ||
        latitude != null ||
        longitude != null ||
        radius != null;
  }

  /// Get active filter count
  int get activeFilterCount {
    int count = 0;
    if (query != null && query!.isNotEmpty) count++;
    if (category != null) count++;
    if (location != null) count++;
    if (minBudget != null || maxBudget != null) count++;
    if (budgetType != null) count++;
    if (skills.isNotEmpty) count++;
    if (minRating != null) count++;
    if (isVerified != null) count++;
    if (sortBy != null) count++;
    if (dateFrom != null || dateTo != null) count++;
    if (latitude != null || longitude != null) count++;
    return count;
  }

  /// Create SearchFilters from JSON
  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    return SearchFilters(
      query: json['query'] as String?,
      category: json['category'] as String?,
      location: json['location'] as String?,
      minBudget: json['min_budget'] as double?,
      maxBudget: json['max_budget'] as double?,
      budgetType: json['budget_type'] as String?,
      skills: List<String>.from(json['skills'] ?? []),
      minRating: json['min_rating'] as double?,
      isVerified: json['is_verified'] as bool?,
      sortBy: json['sort_by'] as String?,
      sortOrder: json['sort_order'] as String?,
      dateFrom: json['date_from'] != null
          ? DateTime.parse(json['date_from'] as String)
          : null,
      dateTo: json['date_to'] != null
          ? DateTime.parse(json['date_to'] as String)
          : null,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      radius: json['radius'] as double?,
      customFilters: json['custom_filters'] as Map<String, dynamic>?,
    );
  }

  /// Convert SearchFilters to JSON
  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'category': category,
      'location': location,
      'min_budget': minBudget,
      'max_budget': maxBudget,
      'budget_type': budgetType,
      'skills': skills,
      'min_rating': minRating,
      'is_verified': isVerified,
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'date_from': dateFrom?.toIso8601String(),
      'date_to': dateTo?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'custom_filters': customFilters,
    };
  }

  /// Create a copy with updated fields
  SearchFilters copyWith({
    String? query,
    String? category,
    String? location,
    double? minBudget,
    double? maxBudget,
    String? budgetType,
    List<String>? skills,
    double? minRating,
    bool? isVerified,
    String? sortBy,
    String? sortOrder,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? latitude,
    double? longitude,
    double? radius,
    Map<String, dynamic>? customFilters,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      category: category ?? this.category,
      location: location ?? this.location,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      budgetType: budgetType ?? this.budgetType,
      skills: skills ?? this.skills,
      minRating: minRating ?? this.minRating,
      isVerified: isVerified ?? this.isVerified,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      customFilters: customFilters ?? this.customFilters,
    );
  }

  /// Clear all filters
  SearchFilters clear() {
    return const SearchFilters();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchFilters &&
        other.query == query &&
        other.category == category &&
        other.location == location &&
        other.minBudget == minBudget &&
        other.maxBudget == maxBudget &&
        other.budgetType == budgetType &&
        other.skills == skills &&
        other.minRating == minRating &&
        other.isVerified == isVerified &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder &&
        other.dateFrom == dateFrom &&
        other.dateTo == dateTo &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.radius == radius;
  }

  @override
  int get hashCode {
    return Object.hash(
      query,
      category,
      location,
      minBudget,
      maxBudget,
      budgetType,
      skills,
      minRating,
      isVerified,
      sortBy,
      sortOrder,
      dateFrom,
      dateTo,
      latitude,
      longitude,
      radius,
    );
  }

  @override
  String toString() {
    return 'SearchFilters(query: $query, category: $category, location: $location, activeFilters: $activeFilterCount)';
  }
}

/// Search result model
class SearchResult<T> {
  final List<T> items;
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final bool hasMore;
  final String? nextCursor;
  final Map<String, dynamic>? metadata;

  const SearchResult({
    required this.items,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.hasMore,
    this.nextCursor,
    this.metadata,
  });

  /// Check if result is empty
  bool get isEmpty => items.isEmpty;

  /// Check if result has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Get item count
  int get itemCount => items.length;

  /// Create SearchResult from JSON
  factory SearchResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return SearchResult<T>(
      items: (json['items'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
      hasMore: json['has_more'] as bool? ?? false,
      nextCursor: json['next_cursor'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert SearchResult to JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map((item) => toJsonT(item)).toList(),
      'total_count': totalCount,
      'total_pages': totalPages,
      'current_page': currentPage,
      'has_more': hasMore,
      'next_cursor': nextCursor,
      'metadata': metadata,
    };
  }
}

/// Search suggestion model
class SearchSuggestion {
  final String id;
  final String text;
  final String type;
  final String? category;
  final String? location;
  final int? count;
  final Map<String, dynamic>? metadata;

  const SearchSuggestion({
    required this.id,
    required this.text,
    required this.type,
    this.category,
    this.location,
    this.count,
    this.metadata,
  });

  /// Create SearchSuggestion from JSON
  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      id: json['id'] as String,
      text: json['text'] as String,
      type: json['type'] as String,
      category: json['category'] as String?,
      location: json['location'] as String?,
      count: json['count'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert SearchSuggestion to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'category': category,
      'location': location,
      'count': count,
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchSuggestion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SearchSuggestion(id: $id, text: $text, type: $type)';
  }
}

/// Search categories
enum SearchCategory {
  jobs('jobs', 'Jobs'),
  fundis('fundis', 'Fundis'),
  portfolios('portfolios', 'Portfolios');

  const SearchCategory(this.value, this.displayName);
  final String value;
  final String displayName;

  static SearchCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'jobs':
        return SearchCategory.jobs;
      case 'fundis':
        return SearchCategory.fundis;
      case 'portfolios':
        return SearchCategory.portfolios;
      default:
        return SearchCategory.jobs;
    }
  }
}

/// Sort options
enum SortOption {
  relevance('relevance', 'Relevance'),
  newest('newest', 'Newest'),
  oldest('oldest', 'Oldest'),
  priceLow('price_low', 'Price: Low to High'),
  priceHigh('price_high', 'Price: High to Low'),
  rating('rating', 'Rating'),
  distance('distance', 'Distance');

  const SortOption(this.value, this.displayName);
  final String value;
  final String displayName;

  static SortOption fromString(String value) {
    switch (value.toLowerCase()) {
      case 'relevance':
        return SortOption.relevance;
      case 'newest':
        return SortOption.newest;
      case 'oldest':
        return SortOption.oldest;
      case 'price_low':
        return SortOption.priceLow;
      case 'price_high':
        return SortOption.priceHigh;
      case 'rating':
        return SortOption.rating;
      case 'distance':
        return SortOption.distance;
      default:
        return SortOption.relevance;
    }
  }
}

