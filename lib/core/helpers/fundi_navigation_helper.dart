import 'package:flutter/material.dart';
import '../guards/role_based_route_guard.dart';
import '../../features/auth/services/auth_service.dart';

/// Navigation helper for fundis and multi-role users
/// Provides smart navigation based on user roles and context
class FundiNavigationHelper {
  /// Navigate to a page with role-based access control
  static Future<void> navigateToPage(
    BuildContext context,
    String route, {
    Object? arguments,
    bool replace = false,
  }) async {
    final userRoles = AuthService().currentUser?.roles ?? [];

    if (!RoleBasedRouteGuard.canAccess(
      route,
      userRoles.map((role) => role.value).toList(),
    )) {
      _showAccessDeniedMessage(context);
      return;
    }

    if (replace) {
      Navigator.pushReplacementNamed(context, route, arguments: arguments);
    } else {
      Navigator.pushNamed(context, route, arguments: arguments);
    }
  }

  /// Navigate to home page based on user's primary role
  static void navigateToHome(BuildContext context) {
    final userRoles = AuthService().currentUser?.roles ?? [];
    final homePage = RoleBasedRouteGuard.getHomePage(
      userRoles.map((role) => role.value).toList(),
    );

    Navigator.pushReplacementNamed(context, homePage);
  }

  /// Navigate to appropriate page after login
  static void navigateAfterLogin(BuildContext context, List<String> userRoles) {
    // Check if user needs to complete profile
    final user = AuthService().currentUser;
    if (user?.nidaNumber == null || user?.firstName == null) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    // Navigate to appropriate home page (no admin in mobile)
    final homePage = RoleBasedRouteGuard.getHomePage(userRoles);
    Navigator.pushReplacementNamed(context, homePage);
  }

  /// Show access denied message
  static void _showAccessDeniedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You do not have permission to access this page'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Get available navigation items for current user
  static List<NavigationItem> getAvailableNavigationItems(
    List<String> userRoles,
  ) {
    List<NavigationItem> items = [];

    // Customer navigation items
    if (RoleBasedRouteGuard.isCustomer(userRoles)) {
      items.addAll([
        NavigationItem(
          title: 'Post a Job',
          icon: Icons.add_business,
          route: '/post-job',
          description: 'Post a job and find fundis',
        ),
        NavigationItem(
          title: 'Browse Fundis',
          icon: Icons.search,
          route: '/browse-fundis',
          description: 'Find skilled fundis',
        ),
        NavigationItem(
          title: 'My Jobs',
          icon: Icons.work,
          route: '/my-jobs',
          description: 'Manage your posted jobs',
        ),
        NavigationItem(
          title: 'Rate Fundis',
          icon: Icons.star,
          route: '/rate-fundi',
          description: 'Rate and review fundis',
        ),
      ]);
    }

    // Fundi navigation items
    if (RoleBasedRouteGuard.isFundi(userRoles)) {
      items.addAll([
        NavigationItem(
          title: 'Job Applications',
          icon: Icons.assignment,
          route: '/job-applications',
          description: 'View and manage applications',
        ),
        NavigationItem(
          title: 'My Portfolio',
          icon: Icons.photo_library,
          route: '/my-portfolio',
          description: 'Manage your work portfolio',
        ),
        NavigationItem(
          title: 'Fundi Profile',
          icon: Icons.person,
          route: '/fundi-profile',
          description: 'Update your fundi profile',
        ),
        NavigationItem(
          title: 'Application Status',
          icon: Icons.trending_up,
          route: '/application-status',
          description: 'Track your application progress',
        ),
      ]);
    }

    // Admin features removed - mobile app doesn't need admin functionality

    // Shared navigation items
    items.addAll([
      NavigationItem(
        title: 'Profile',
        icon: Icons.person_outline,
        route: '/profile',
        description: 'Manage your profile',
      ),
      NavigationItem(
        title: 'Settings',
        icon: Icons.settings_outlined,
        route: '/settings',
        description: 'App preferences',
      ),
      NavigationItem(
        title: 'Notifications',
        icon: Icons.notifications,
        route: '/notifications',
        description: 'View notifications',
      ),
    ]);

    return items;
  }

  /// Get role-specific welcome message
  static String getWelcomeMessage(List<String> userRoles) {
    if (userRoles.contains('fundi')) {
      return 'Welcome, Fundi! Ready to find work or post jobs?';
    } else if (userRoles.contains('customer')) {
      return 'Welcome! Find skilled fundis for your projects.';
    }
    return 'Welcome to Fundi App!';
  }

  /// Get role-specific quick actions
  static List<QuickAction> getQuickActions(List<String> userRoles) {
    List<QuickAction> actions = [];

    if (RoleBasedRouteGuard.isCustomer(userRoles)) {
      actions.addAll([
        QuickAction(
          title: 'Post Job',
          icon: Icons.add,
          route: '/post-job',
          color: Colors.blue,
        ),
        QuickAction(
          title: 'Find Fundis',
          icon: Icons.search,
          route: '/browse-fundis',
          color: Colors.green,
        ),
      ]);
    }

    if (RoleBasedRouteGuard.isFundi(userRoles)) {
      actions.addAll([
        QuickAction(
          title: 'Apply to Jobs',
          icon: Icons.assignment,
          route: '/job-applications',
          color: Colors.orange,
        ),
        QuickAction(
          title: 'Update Portfolio',
          icon: Icons.photo_library,
          route: '/my-portfolio',
          color: Colors.purple,
        ),
      ]);
    }

    return actions;
  }
}

/// Navigation item model
class NavigationItem {
  final String title;
  final IconData icon;
  final String route;
  final String description;

  const NavigationItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.description,
  });
}

/// Quick action model
class QuickAction {
  final String title;
  final IconData icon;
  final String route;
  final Color color;

  const QuickAction({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
  });
}
