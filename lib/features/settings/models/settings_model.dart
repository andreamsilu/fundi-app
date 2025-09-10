/// Settings model representing user preferences and app configuration
/// Manages all user-customizable settings
class SettingsModel {
  final String userId;
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final DisplaySettings display;
  final LanguageSettings language;
  final LocationSettings location;
  final PaymentSettings payment;
  final Map<String, dynamic>? customSettings;
  final DateTime updatedAt;

  const SettingsModel({
    required this.userId,
    required this.notifications,
    required this.privacy,
    required this.display,
    required this.language,
    required this.location,
    required this.payment,
    this.customSettings,
    required this.updatedAt,
  });

  /// Create SettingsModel from JSON
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      userId: json['user_id'] as String,
      notifications: NotificationSettings.fromJson(
        json['notifications'] as Map<String, dynamic>,
      ),
      privacy: PrivacySettings.fromJson(
        json['privacy'] as Map<String, dynamic>,
      ),
      display: DisplaySettings.fromJson(
        json['display'] as Map<String, dynamic>,
      ),
      language: LanguageSettings.fromJson(
        json['language'] as Map<String, dynamic>,
      ),
      location: LocationSettings.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      payment: PaymentSettings.fromJson(
        json['payment'] as Map<String, dynamic>,
      ),
      customSettings: json['custom_settings'] as Map<String, dynamic>?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert SettingsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'notifications': notifications.toJson(),
      'privacy': privacy.toJson(),
      'display': display.toJson(),
      'language': language.toJson(),
      'location': location.toJson(),
      'payment': payment.toJson(),
      'custom_settings': customSettings,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  SettingsModel copyWith({
    String? userId,
    NotificationSettings? notifications,
    PrivacySettings? privacy,
    DisplaySettings? display,
    LanguageSettings? language,
    LocationSettings? location,
    PaymentSettings? payment,
    Map<String, dynamic>? customSettings,
    DateTime? updatedAt,
  }) {
    return SettingsModel(
      userId: userId ?? this.userId,
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
      display: display ?? this.display,
      language: language ?? this.language,
      location: location ?? this.location,
      payment: payment ?? this.payment,
      customSettings: customSettings ?? this.customSettings,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsModel && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'SettingsModel(userId: $userId, updatedAt: $updatedAt)';
  }
}

/// Notification settings
class NotificationSettings {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool jobAlerts;
  final bool messageAlerts;
  final bool paymentAlerts;
  final bool systemAlerts;
  final bool marketingAlerts;
  final String quietHoursStart;
  final String quietHoursEnd;
  final List<String> quietDays;

  const NotificationSettings({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.jobAlerts = true,
    this.messageAlerts = true,
    this.paymentAlerts = true,
    this.systemAlerts = true,
    this.marketingAlerts = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
    this.quietDays = const [],
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotifications: json['push_notifications'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool? ?? true,
      smsNotifications: json['sms_notifications'] as bool? ?? false,
      jobAlerts: json['job_alerts'] as bool? ?? true,
      messageAlerts: json['message_alerts'] as bool? ?? true,
      paymentAlerts: json['payment_alerts'] as bool? ?? true,
      systemAlerts: json['system_alerts'] as bool? ?? true,
      marketingAlerts: json['marketing_alerts'] as bool? ?? false,
      quietHoursStart: json['quiet_hours_start'] as String? ?? '22:00',
      quietHoursEnd: json['quiet_hours_end'] as String? ?? '08:00',
      quietDays: List<String>.from(json['quiet_days'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_notifications': pushNotifications,
      'email_notifications': emailNotifications,
      'sms_notifications': smsNotifications,
      'job_alerts': jobAlerts,
      'message_alerts': messageAlerts,
      'payment_alerts': paymentAlerts,
      'system_alerts': systemAlerts,
      'marketing_alerts': marketingAlerts,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'quiet_days': quietDays,
    };
  }
}

/// Privacy settings
class PrivacySettings {
  final bool profileVisible;
  final bool locationVisible;
  final bool contactVisible;
  final bool portfolioVisible;
  final bool showOnlineStatus;
  final bool allowMessages;
  final bool allowJobInvites;
  final String dataSharing;

  const PrivacySettings({
    this.profileVisible = true,
    this.locationVisible = true,
    this.contactVisible = false,
    this.portfolioVisible = true,
    this.showOnlineStatus = true,
    this.allowMessages = true,
    this.allowJobInvites = true,
    this.dataSharing = 'limited',
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      profileVisible: json['profile_visible'] as bool? ?? true,
      locationVisible: json['location_visible'] as bool? ?? true,
      contactVisible: json['contact_visible'] as bool? ?? false,
      portfolioVisible: json['portfolio_visible'] as bool? ?? true,
      showOnlineStatus: json['show_online_status'] as bool? ?? true,
      allowMessages: json['allow_messages'] as bool? ?? true,
      allowJobInvites: json['allow_job_invites'] as bool? ?? true,
      dataSharing: json['data_sharing'] as String? ?? 'limited',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_visible': profileVisible,
      'location_visible': locationVisible,
      'contact_visible': contactVisible,
      'portfolio_visible': portfolioVisible,
      'show_online_status': showOnlineStatus,
      'allow_messages': allowMessages,
      'allow_job_invites': allowJobInvites,
      'data_sharing': dataSharing,
    };
  }
}

/// Display settings
class DisplaySettings {
  final String theme;
  final String fontSize;
  final bool animationsEnabled;
  final bool hapticFeedback;
  final String currency;
  final String dateFormat;
  final String timeFormat;

  const DisplaySettings({
    this.theme = 'light',
    this.fontSize = 'medium',
    this.animationsEnabled = true,
    this.hapticFeedback = true,
    this.currency = 'TZS',
    this.dateFormat = 'DD/MM/YYYY',
    this.timeFormat = '24h',
  });

  factory DisplaySettings.fromJson(Map<String, dynamic> json) {
    return DisplaySettings(
      theme: json['theme'] as String? ?? 'light',
      fontSize: json['font_size'] as String? ?? 'medium',
      animationsEnabled: json['animations_enabled'] as bool? ?? true,
      hapticFeedback: json['haptic_feedback'] as bool? ?? true,
      currency: json['currency'] as String? ?? 'TZS',
      dateFormat: json['date_format'] as String? ?? 'DD/MM/YYYY',
      timeFormat: json['time_format'] as String? ?? '24h',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'font_size': fontSize,
      'animations_enabled': animationsEnabled,
      'haptic_feedback': hapticFeedback,
      'currency': currency,
      'date_format': dateFormat,
      'time_format': timeFormat,
    };
  }
}

/// Language settings
class LanguageSettings {
  final String language;
  final String region;
  final bool autoTranslate;

  const LanguageSettings({
    this.language = 'en',
    this.region = 'TZ',
    this.autoTranslate = false,
  });

  factory LanguageSettings.fromJson(Map<String, dynamic> json) {
    return LanguageSettings(
      language: json['language'] as String? ?? 'en',
      region: json['region'] as String? ?? 'TZ',
      autoTranslate: json['auto_translate'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'region': region,
      'auto_translate': autoTranslate,
    };
  }
}

/// Location settings
class LocationSettings {
  final bool locationEnabled;
  final bool locationSharing;
  final double? defaultLatitude;
  final double? defaultLongitude;
  final String? defaultLocation;
  final int searchRadius;

  const LocationSettings({
    this.locationEnabled = true,
    this.locationSharing = true,
    this.defaultLatitude,
    this.defaultLongitude,
    this.defaultLocation,
    this.searchRadius = 50,
  });

  factory LocationSettings.fromJson(Map<String, dynamic> json) {
    return LocationSettings(
      locationEnabled: json['location_enabled'] as bool? ?? true,
      locationSharing: json['location_sharing'] as bool? ?? true,
      defaultLatitude: json['default_latitude'] as double?,
      defaultLongitude: json['default_longitude'] as double?,
      defaultLocation: json['default_location'] as String?,
      searchRadius: json['search_radius'] as int? ?? 50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_enabled': locationEnabled,
      'location_sharing': locationSharing,
      'default_latitude': defaultLatitude,
      'default_longitude': defaultLongitude,
      'default_location': defaultLocation,
      'search_radius': searchRadius,
    };
  }
}

/// Payment settings
class PaymentSettings {
  final String preferredMethod;
  final bool autoPayment;
  final bool paymentNotifications;
  final String? bankAccount;
  final String? mobileMoneyNumber;
  final String? mobileMoneyProvider;

  const PaymentSettings({
    this.preferredMethod = 'mobile_money',
    this.autoPayment = false,
    this.paymentNotifications = true,
    this.bankAccount,
    this.mobileMoneyNumber,
    this.mobileMoneyProvider,
  });

  factory PaymentSettings.fromJson(Map<String, dynamic> json) {
    return PaymentSettings(
      preferredMethod: json['preferred_method'] as String? ?? 'mobile_money',
      autoPayment: json['auto_payment'] as bool? ?? false,
      paymentNotifications: json['payment_notifications'] as bool? ?? true,
      bankAccount: json['bank_account'] as String?,
      mobileMoneyNumber: json['mobile_money_number'] as String?,
      mobileMoneyProvider: json['mobile_money_provider'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferred_method': preferredMethod,
      'auto_payment': autoPayment,
      'payment_notifications': paymentNotifications,
      'bank_account': bankAccount,
      'mobile_money_number': mobileMoneyNumber,
      'mobile_money_provider': mobileMoneyProvider,
    };
  }
}
