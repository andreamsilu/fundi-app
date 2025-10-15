import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/onboarding_page_model.dart';

/// Configuration class for onboarding pages
/// Centralizes all onboarding page definitions for easy maintenance
class OnboardingPages {
  /// Get all onboarding pages
  static List<OnboardingPageModel> get pages => [
    // Page 1: Welcome
    OnboardingPageModel(
      title: 'Welcome to Fundi App',
      description:
          'Connect with skilled craftsmen and get your projects done professionally.',
      image: Icons.build,
      isAssetImage: false,
      color: AppTheme.primaryGreen,
      features: [
        'Find Local Craftsmen',
        'Post Your Project',
        'Get Instant Quotes',
      ],
      demoText: 'Tap to see how it works!',
    ),

    // Page 2: Find Professionals
    OnboardingPageModel(
      title: 'Find the Right Professional',
      description:
          'Browse through verified craftsmen in your area and choose the best fit for your project.',
      image: Icons.search,
      isAssetImage: false,
      color: AppTheme.accentGreen,
      features: ['Search by Category', 'View Portfolios', 'Read Reviews'],
      demoText: 'Swipe to explore craftsmen',
    ),

    // Page 3: Quality Work
    OnboardingPageModel(
      title: 'Get Quality Work Done',
      description:
          'Hire experienced professionals who deliver quality work on time and within budget.',
      image: Icons.verified,
      isAssetImage: false,
      color: AppTheme.successColor,
      features: [
        'Verified Professionals',
        'Quality Guarantee',
        'On-time Delivery',
      ],
      demoText: 'Tap to see success stories',
    ),

    // Page 4: Communication
    OnboardingPageModel(
      title: 'Easy Communication',
      description:
          'Chat directly with craftsmen, share project details, and track progress in real-time.',
      image: Icons.chat,
      isAssetImage: false,
      color: AppTheme.infoColor,
      features: ['Real-time Chat', 'Photo Sharing', 'Progress Updates'],
      demoText: 'Tap to start chatting',
    ),
  ];

  /// Get page count
  static int get pageCount => pages.length;

  /// Get a specific page by index
  static OnboardingPageModel getPage(int index) {
    if (index < 0 || index >= pages.length) {
      throw RangeError('Invalid page index: $index');
    }
    return pages[index];
  }

  /// Check if index is the last page
  static bool isLastPage(int index) {
    return index == pages.length - 1;
  }

  /// Check if index is the first page
  static bool isFirstPage(int index) {
    return index == 0;
  }
}

