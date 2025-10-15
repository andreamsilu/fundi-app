import 'package:flutter/material.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/auth/models/user_model.dart';

/// Role-based access control guard
/// Ensures users can only access pages appropriate for their role
class RoleGuard {
  /// Check if user can access a specific route based on their roles
  static bool canAccessRoute(String routeName, List<UserRole> userRoles) {
    // Define role-based route access rules
    switch (routeName) {
      // Public routes (accessible to all authenticated users)
      case '/dashboard':
      case '/profile':
      case '/notifications':
      case '/settings':
      case '/help':
      case '/portfolio-details':
        return true;

      // Customer-only routes
      case '/fundi-application':
        return userRoles.contains(UserRole.customer);

      // Fundi-only routes
      case '/create-portfolio':
        return userRoles.contains(UserRole.fundi);

      // Admin-only routes (if any)
      case '/admin':
        return userRoles.contains(UserRole.admin);

      // Job-related routes (both customers and fundis can access)
      case '/create-job':
      case '/job-details':
        return userRoles.contains(UserRole.customer) ||
            userRoles.contains(UserRole.fundi);

      // Search and messaging (both customers and fundis can access)
      case '/search':
      case '/chat':
        return userRoles.contains(UserRole.customer) ||
            userRoles.contains(UserRole.fundi);

      // Default: deny access
      default:
        return false;
    }
  }

  /// Check if user can access a specific route based on a single role (backward compatibility)
  static bool canAccessRouteWithSingleRole(
    String routeName,
    UserRole userRole,
  ) {
    return canAccessRoute(routeName, [userRole]);
  }

  /// Check if user can access route with context
  static bool canAccessRouteWithContext(
    BuildContext context,
    String routeName,
  ) {
    // Use AuthService directly instead of Provider
    final authService = AuthService();
    final user = authService.currentUser;

    if (user == null) {
      return false;
    }

    return canAccessRoute(routeName, user.roles);
  }

  /// Get appropriate redirect route based on user roles
  static String getRedirectRouteForRoles(List<UserRole> roles) {
    // Priority: Admin > Fundi > Customer
    if (roles.contains(UserRole.admin)) {
      return '/dashboard';
    } else if (roles.contains(UserRole.fundi)) {
      return '/dashboard';
    } else if (roles.contains(UserRole.customer)) {
      return '/dashboard';
    }
    return '/dashboard'; // Default fallback
  }

  /// Get appropriate redirect route based on user role (backward compatibility)
  static String getRedirectRouteForRole(UserRole role) {
    return getRedirectRouteForRoles([role]);
  }

  /// Get appropriate redirect route with context
  static String getRedirectRouteWithContext(BuildContext context) {
    // Use AuthService directly instead of Provider
    final authService = AuthService();
    final user = authService.currentUser;

    if (user == null) {
      return '/login';
    }

    return getRedirectRouteForRoles(user.roles);
  }

  /// Check if user has specific role
  static bool hasRole(BuildContext context, UserRole requiredRole) {
    // Use AuthService directly instead of Provider
    final authService = AuthService();
    final user = authService.currentUser;

    return user?.roles.contains(requiredRole) ?? false;
  }

  /// Check if user has any of the specified roles
  static bool hasAnyRole(BuildContext context, List<UserRole> requiredRoles) {
    // Use AuthService directly instead of Provider
    final authService = AuthService();
    final user = authService.currentUser;

    if (user == null) return false;

    return requiredRoles.any((role) => user.roles.contains(role));
  }

  /// Check if user is customer
  static bool isCustomer(BuildContext context) {
    return hasRole(context, UserRole.customer);
  }

  /// Check if user is fundi
  static bool isFundi(BuildContext context) {
    return hasRole(context, UserRole.fundi);
  }

  /// Check if user is admin
  static bool isAdmin(BuildContext context) {
    return hasRole(context, UserRole.admin);
  }

  /// Get role-specific navigation items
  static List<NavigationItem> getNavigationItemsForRole(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return [
          NavigationItem(
            route: '/dashboard',
            icon: Icons.home,
            label: 'Home',
            description: 'Available Jobs',
          ),
          NavigationItem(
            route: '/create-job',
            icon: Icons.add_circle,
            label: 'Post Job',
            description: 'Create new job posting',
          ),
          NavigationItem(
            route: '/search',
            icon: Icons.search,
            label: 'Find Fundis',
            description: 'Search for skilled craftsmen',
          ),
          NavigationItem(
            route: '/fundi-application',
            icon: Icons.build_circle,
            label: 'Become Fundi',
            description: 'Apply to become a fundi',
          ),
          NavigationItem(
            route: '/profile',
            icon: Icons.person,
            label: 'Profile',
            description: 'Manage your profile',
          ),
        ];

      case UserRole.fundi:
        return [
          NavigationItem(
            route: '/dashboard',
            icon: Icons.home,
            label: 'Home',
            description: 'Available Jobs',
          ),
          NavigationItem(
            route: '/search',
            icon: Icons.search,
            label: 'Search Jobs',
            description: 'Find available jobs',
          ),
          NavigationItem(
            route: '/create-portfolio',
            icon: Icons.add_a_photo,
            label: 'Add Portfolio',
            description: 'Showcase your work',
          ),
          NavigationItem(
            route: '/profile',
            icon: Icons.person,
            label: 'Profile',
            description: 'Manage your profile',
          ),
        ];

      case UserRole.admin:
        return [
          NavigationItem(
            route: '/dashboard',
            icon: Icons.dashboard,
            label: 'Dashboard',
            description: 'Admin dashboard',
          ),
          NavigationItem(
            route: '/admin',
            icon: Icons.admin_panel_settings,
            label: 'Admin Panel',
            description: 'System administration',
          ),
          NavigationItem(
            route: '/profile',
            icon: Icons.person,
            label: 'Profile',
            description: 'Manage your profile',
          ),
        ];
    }
  }

  /// Get bottom navigation items for a specific role (for BottomNavigationBar)
  /// Returns fewer items optimized for bottom navigation (3 items max)
  /// Note: Admin role not supported on mobile app
  static List<BottomNavItem> getBottomNavItemsForRole(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return [
          BottomNavItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Find Fundis',
            route: '/fundi-feed',
          ),
          BottomNavItem(
            icon: Icons.work_outline,
            activeIcon: Icons.work,
            label: 'My Jobs',
            route: '/my-jobs',
          ),
          BottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            route: '/profile',
          ),
        ];

      case UserRole.fundi:
        return [
          BottomNavItem(
            icon: Icons.work_outline,
            activeIcon: Icons.work,
            label: 'Available Jobs',
            route: '/dashboard',
          ),
          BottomNavItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
            label: 'Applied',
            route: '/applied-jobs',
          ),
          BottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            route: '/profile',
          ),
        ];

      case UserRole.admin:
        // Admin not supported on mobile - use web admin panel instead
        // Fallback to customer navigation
        return getBottomNavItemsForRole(UserRole.customer);
    }
  }

  /// Show access denied dialog
  static void showAccessDeniedDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.block, color: Colors.red),
            SizedBox(width: 8),
            Text('Access Denied'),
          ],
        ),
        content: Text(
          message ?? 'You do not have permission to access this page.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Navigate with role check
  static Future<T?> navigateWithRoleCheck<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    String? fallbackRoute,
  }) {
    if (canAccessRouteWithContext(context, routeName)) {
      return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
    } else {
      showAccessDeniedDialog(context);
      if (fallbackRoute != null) {
        return Navigator.pushNamed<T>(
          context,
          fallbackRoute,
          arguments: arguments,
        );
      }
      return Future.value(null);
    }
  }
}

/// Navigation item model (for drawer/menu navigation)
class NavigationItem {
  final String route;
  final IconData icon;
  final String label;
  final String description;
  final bool isEnabled;

  const NavigationItem({
    required this.route,
    required this.icon,
    required this.label,
    required this.description,
    this.isEnabled = true,
  });
}

/// Bottom navigation item model (for BottomNavigationBar)
class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final bool isEnabled;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.isEnabled = true,
  });
}
