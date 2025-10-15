import 'package:flutter/material.dart';

/// Model representing a single onboarding page
/// Contains all data needed to display an onboarding screen
class OnboardingPageModel {
  /// Title of the onboarding page
  final String title;

  /// Description text explaining the feature
  final String description;

  /// Image path or icon to display
  /// Can be either an asset path (String) or IconData for now
  final dynamic image;

  /// Whether the image is an asset path or icon
  final bool isAssetImage;

  /// Primary color for this page
  final Color color;

  /// List of key features to highlight
  final List<String> features;

  /// Interactive demo text hint
  final String demoText;

  /// Optional video path for advanced demos
  final String? videoPath;

  /// Optional lottie animation path
  final String? lottiePath;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.image,
    this.isAssetImage = false,
    required this.color,
    required this.features,
    required this.demoText,
    this.videoPath,
    this.lottiePath,
  });

  /// Create a copy with updated fields
  OnboardingPageModel copyWith({
    String? title,
    String? description,
    dynamic image,
    bool? isAssetImage,
    Color? color,
    List<String>? features,
    String? demoText,
    String? videoPath,
    String? lottiePath,
  }) {
    return OnboardingPageModel(
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      isAssetImage: isAssetImage ?? this.isAssetImage,
      color: color ?? this.color,
      features: features ?? this.features,
      demoText: demoText ?? this.demoText,
      videoPath: videoPath ?? this.videoPath,
      lottiePath: lottiePath ?? this.lottiePath,
    );
  }

  /// Convert to JSON for analytics or storage
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'color': color.value,
      'features_count': features.length,
      'has_video': videoPath != null,
      'has_lottie': lottiePath != null,
    };
  }
}

