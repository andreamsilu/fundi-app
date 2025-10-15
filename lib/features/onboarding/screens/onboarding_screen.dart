import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../services/onboarding_service.dart';
import '../services/onboarding_analytics.dart';
import '../models/onboarding_page_model.dart';
import '../config/onboarding_pages.dart';
import '../config/onboarding_constants.dart';

/// Onboarding screen that introduces users to the app
/// Shows multiple pages with app features and benefits
///
/// Features:
/// - Smooth animations and transitions
/// - Interactive demos
/// - Haptic feedback
/// - Progress tracking
/// - Accessibility support
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  // Use centralized configuration
  late List<OnboardingPageModel> _pages;

  @override
  void initState() {
    super.initState();
    // Load pages from configuration
    _pages = OnboardingPages.pages;
    _initializeAnimations();
    _startInitialAnimation();

    // Log onboarding start
    OnboardingAnalytics.logOnboardingStart();
    OnboardingAnalytics.logPageView(0, _pages[0]);
  }

  void _initializeAnimations() {
    // Initialize animation controllers with constants
    _fadeController = AnimationController(
      duration: Duration(
        milliseconds: OnboardingConstants.fadeAnimationDuration,
      ),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(
        milliseconds: OnboardingConstants.slideAnimationDuration,
      ),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(
        milliseconds: OnboardingConstants.scaleAnimationDuration,
      ),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: Duration(
        milliseconds: OnboardingConstants.rotationAnimationDuration,
      ),
      vsync: this,
    );

    // Create animations with constants
    _fadeAnimation =
        Tween<double>(
          begin: OnboardingConstants.fadeBegin,
          end: OnboardingConstants.fadeEnd,
        ).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
        );
    _slideAnimation =
        Tween<Offset>(
          begin: Offset(0, OnboardingConstants.slideOffsetY),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _scaleAnimation =
        Tween<double>(
          begin: OnboardingConstants.scaleBegin,
          end: OnboardingConstants.scaleEnd,
        ).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
        );
    _rotationAnimation =
        Tween<double>(
          begin: OnboardingConstants.fadeBegin,
          end: OnboardingConstants.fadeEnd,
        ).animate(
          CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
        );
  }

  void _startInitialAnimation() {
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();

    if (!OnboardingPages.isLastPage(_currentPage)) {
      final toPage = _currentPage + 1;
      OnboardingAnalytics.logNextPage(_currentPage, toPage);

      _pageController.nextPage(
        duration: Duration(
          milliseconds: OnboardingConstants.pageTransitionDuration,
        ),
        curve: Curves.easeInOutCubic,
      );
      _restartAnimations();
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    HapticFeedback.lightImpact();

    if (!OnboardingPages.isFirstPage(_currentPage)) {
      final toPage = _currentPage - 1;
      OnboardingAnalytics.logPreviousPage(_currentPage, toPage);

      _pageController.previousPage(
        duration: Duration(
          milliseconds: OnboardingConstants.pageTransitionDuration,
        ),
        curve: Curves.easeInOutCubic,
      );
      _restartAnimations();
    }
  }

  void _restartAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _scaleController.reset();
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _skipOnboarding() {
    OnboardingAnalytics.logSkip(_currentPage, _pages.length);
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    OnboardingAnalytics.logComplete();

    // Mark onboarding as completed
    await OnboardingService.completeOnboarding();

    // Navigate back to AppInitializer which will now show the login screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Semantics(
        label:
            'Onboarding screen, page ${_currentPage + 1} of ${_pages.length}',
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _pages[_currentPage].color.withValues(alpha: 0.1),
                Colors.white,
                _pages[_currentPage].color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Progress indicator and skip button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Progress bar
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                            width:
                                MediaQuery.of(context).size.width *
                                ((_currentPage + 1) / _pages.length),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _pages[_currentPage].color,
                                  _pages[_currentPage].color.withValues(
                                    alpha: 0.8,
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: _pages[_currentPage].color.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Skip button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_currentPage + 1} of ${_pages.length}',
                              style: TextStyle(
                                color: AppTheme.mediumGray,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Semantics(
                              label: 'Skip onboarding button',
                              hint:
                                  'Skip the onboarding tour and go directly to login',
                              child: TextButton(
                                onPressed: _skipOnboarding,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: OnboardingConstants
                                        .skipButtonHorizontalPadding,
                                    vertical: OnboardingConstants
                                        .skipButtonVerticalPadding,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      OnboardingConstants
                                          .skipButtonBorderRadius,
                                    ),
                                  ),
                                ),
                                child: const Text('Skip'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Page view with enhanced animations
                Expanded(
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      // Add haptic feedback on swipe
                      if (details.delta.dx.abs() > 10) {
                        HapticFeedback.selectionClick();
                      }
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                        _restartAnimations();
                        // Log page view
                        OnboardingAnalytics.logPageView(index, _pages[index]);
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return _buildAnimatedPageWithTransition(
                          _pages[index],
                          index,
                        );
                      },
                    ),
                  ),
                ),

                // Interactive page indicators
                SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => _buildAnimatedPageIndicator(index),
                      ),
                    ),
                  ),
                ),

                // Navigation buttons
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Previous button
                        if (_currentPage > 0)
                          Expanded(
                            child: Semantics(
                              label: 'Previous page button',
                              hint: 'Go back to page ${_currentPage}',
                              child: OutlinedButton(
                                onPressed: _previousPage,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _pages[_currentPage].color,
                                  side: BorderSide(
                                    color: _pages[_currentPage].color,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_back, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Previous',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        if (_currentPage > 0) const SizedBox(width: 16),

                        // Next/Get Started button
                        Expanded(
                          flex: _currentPage > 0 ? 1 : 2,
                          child: Semantics(
                            label: _currentPage == _pages.length - 1
                                ? 'Get Started button'
                                : 'Next page button',
                            hint: _currentPage == _pages.length - 1
                                ? 'Complete onboarding and start using the app'
                                : 'Go to page ${_currentPage + 2}',
                            child: ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _pages[_currentPage].color,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                                shadowColor: _pages[_currentPage].color
                                    .withValues(alpha: 0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentPage == _pages.length - 1
                                        ? 'Get Started'
                                        : 'Next',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedRotation(
                                    turns: _rotationAnimation.value * 2,
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    child: Icon(
                                      _currentPage == _pages.length - 1
                                          ? Icons.rocket_launch
                                          : Icons.arrow_forward,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedPageWithTransition(OnboardingPageModel page, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 0.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(value * 0.1)
            ..scale(0.8 + (value * 0.2)),
          child: Opacity(
            opacity: value,
            child: _buildAnimatedPage(page, index),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedPage(OnboardingPageModel page, int index) {
    return Semantics(
      label: '${page.title}. ${page.description}',
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Icon with interactive demo
                  GestureDetector(
                    onTap: () => _showInteractiveDemo(page),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              page.color.withValues(alpha: 0.2),
                              page.color.withValues(alpha: 0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: page.color.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: AnimatedRotation(
                          turns: _rotationAnimation.value * 0.1,
                          duration: const Duration(milliseconds: 2000),
                          child: Icon(page.image, size: 100, color: page.color),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Animated Title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      page.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppTheme.darkGray,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Animated Description
                  SlideTransition(
                    position: _slideAnimation,
                    child: Text(
                      page.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.mediumGray,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Interactive Features List
                  _buildFeaturesList(page),

                  const SizedBox(height: 16),

                  // Demo hint
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: page.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: page.color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        page.demoText,
                        style: TextStyle(
                          color: page.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(OnboardingPageModel page) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: page.features.asMap().entries.map((entry) {
          int index = entry.key;
          String feature = entry.value;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: page.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: page.color, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          feature,
                          style: TextStyle(
                            color: page.color,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  void _showInteractiveDemo(OnboardingPageModel page) {
    HapticFeedback.mediumImpact();
    OnboardingAnalytics.logDemoInteraction(page.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            OnboardingConstants.demoDialogBorderRadius,
          ),
        ),
        title: Text('${page.title} Demo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(page.image, size: 60, color: page.color),
            const SizedBox(height: 16),
            Text(
              'This is how ${page.title.toLowerCase()} works in the app!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPageIndicator(int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        OnboardingAnalytics.logPageIndicatorTap(index);
        _pageController.animateToPage(
          index,
          duration: Duration(
            milliseconds: OnboardingConstants.pageTransitionDuration,
          ),
          curve: Curves.easeInOutCubic,
        );
        _restartAnimations();
      },
      child: AnimatedBuilder(
        animation: _pageController,
        builder: (context, child) {
          double value = 0.0;
          if (_pageController.position.haveDimensions) {
            value = _pageController.page! - index;
            value = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 32 + (value * 8) : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? _pages[_currentPage].color
                  : AppTheme.lightGray.withValues(alpha: 0.3 + (value * 0.7)),
              borderRadius: BorderRadius.circular(4),
              boxShadow: _currentPage == index
                  ? [
                      BoxShadow(
                        color: _pages[_currentPage].color.withValues(
                          alpha: 0.3 + (value * 0.2),
                        ),
                        blurRadius: 8 + (value * 4),
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: _currentPage == index
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          _pages[_currentPage].color,
                          _pages[_currentPage].color.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}
