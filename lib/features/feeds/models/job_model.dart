/// Job model representing a job posting with all relevant information
class JobModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final double budget;
  final String currency;
  final String status; // pending, in_progress, completed, cancelled
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? customerEmail;
  final List<String> requiredSkills;
  final List<String> attachments;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> budgetBreakdown;
  final int estimatedDuration; // in hours
  final String priority; // low, medium, high, urgent
  final bool isUrgent;
  final List<String> tags;
  final Map<String, dynamic> requirements;

  const JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.budget,
    required this.currency,
    required this.status,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.customerEmail,
    required this.requiredSkills,
    required this.attachments,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    required this.budgetBreakdown,
    required this.estimatedDuration,
    required this.priority,
    required this.isUrgent,
    required this.tags,
    required this.requirements,
  });

  /// Create JobModel from JSON
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      budget: (json['budget'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'TSh',
      status: json['status'] ?? 'pending',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'],
      customerEmail: json['customerEmail'],
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      attachments: List<String>.from(json['attachments'] ?? []),
      deadline: DateTime.parse(
        json['deadline'] ??
            DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      budgetBreakdown: Map<String, dynamic>.from(json['budgetBreakdown'] ?? {}),
      estimatedDuration: json['estimatedDuration'] ?? 0,
      priority: json['priority'] ?? 'medium',
      isUrgent: json['isUrgent'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      requirements: Map<String, dynamic>.from(json['requirements'] ?? {}),
    );
  }

  /// Convert JobModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'budget': budget,
      'currency': currency,
      'status': status,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'requiredSkills': requiredSkills,
      'attachments': attachments,
      'deadline': deadline.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'budgetBreakdown': budgetBreakdown,
      'estimatedDuration': estimatedDuration,
      'priority': priority,
      'isUrgent': isUrgent,
      'tags': tags,
      'requirements': requirements,
    };
  }

  /// Create empty JobModel
  factory JobModel.empty() {
    final now = DateTime.now();
    return JobModel(
      id: '',
      title: '',
      description: '',
      category: '',
      location: '',
      budget: 0.0,
      currency: 'TSh',
      status: 'pending',
      customerId: '',
      customerName: '',
      requiredSkills: [],
      attachments: [],
      deadline: now.add(const Duration(days: 7)),
      createdAt: now,
      updatedAt: now,
      budgetBreakdown: {},
      estimatedDuration: 0,
      priority: 'medium',
      isUrgent: false,
      tags: [],
      requirements: {},
    );
  }

  /// Copy with new values
  JobModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? location,
    double? budget,
    String? currency,
    String? status,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    List<String>? requiredSkills,
    List<String>? attachments,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? budgetBreakdown,
    int? estimatedDuration,
    String? priority,
    bool? isUrgent,
    List<String>? tags,
    Map<String, dynamic>? requirements,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      attachments: attachments ?? this.attachments,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      budgetBreakdown: budgetBreakdown ?? this.budgetBreakdown,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      priority: priority ?? this.priority,
      isUrgent: isUrgent ?? this.isUrgent,
      tags: tags ?? this.tags,
      requirements: requirements ?? this.requirements,
    );
  }

  /// Get formatted budget
  String get formattedBudget {
    return '$currency ${budget.toStringAsFixed(0)}';
  }

  /// Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'warning';
      case 'in_progress':
        return 'info';
      case 'completed':
        return 'success';
      case 'cancelled':
        return 'error';
      default:
        return 'warning';
    }
  }

  /// Check if job is expired
  bool get isExpired {
    return DateTime.now().isAfter(deadline);
  }

  /// Get days until deadline
  int get daysUntilDeadline {
    return deadline.difference(DateTime.now()).inDays;
  }

  /// Get formatted deadline
  String get formattedDeadline {
    final days = daysUntilDeadline;
    if (days < 0) return 'Expired';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }

  /// Check if job requires specific skill
  bool requiresSkill(String skill) {
    return requiredSkills.any(
      (s) => s.toLowerCase().contains(skill.toLowerCase()),
    );
  }

  /// Get priority level
  int get priorityLevel {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 4;
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 2;
    }
  }
}
