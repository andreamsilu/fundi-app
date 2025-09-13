/// Role-based route access control
/// Ensures users can only access pages they have permission for
class RoleBasedRouteGuard {
  /// Page access matrix defining which roles can access which pages
  static const Map<String, List<String>> pageAccess = {
    // Customer pages (accessible by both customers and fundis)
    '/customer-home': ['customer', 'fundi'],
    '/post-job': ['customer', 'fundi'],
    '/browse-fundis': ['customer', 'fundi'],
    '/my-jobs': ['customer', 'fundi'],
    '/rate-fundi': ['customer', 'fundi'],
    '/payment-management': ['customer', 'fundi'],
    '/job-details': ['customer', 'fundi'],
    '/fundi-details': ['customer', 'fundi'],
    
    // Fundi-specific pages (only fundis)
    '/fundi-home': ['fundi'],
    '/job-applications': ['fundi'],
    '/my-portfolio': ['fundi'],
    '/fundi-profile': ['fundi'],
    '/application-status': ['fundi'],
    '/portfolio-edit': ['fundi'],
    '/fundi-application': ['fundi'],
    
    // Admin pages removed - mobile app doesn't need admin functionality
    
    // Shared pages (all roles)
    '/profile': ['customer', 'fundi'],
    '/settings': ['customer', 'fundi'],
    '/notifications': ['customer', 'fundi'],
    '/help': ['customer', 'fundi'],
    '/about': ['customer', 'fundi'],
    
    // Auth pages (public)
    '/login': [],
    '/register': [],
    '/forgot-password': [],
    '/otp-verification': [],
  };

  /// Check if user can access a specific route
  static bool canAccess(String route, List<String> userRoles) {
    final allowedRoles = pageAccess[route] ?? [];
    
    // If no roles specified, it's a public route
    if (allowedRoles.isEmpty) return true;
    
    // Check if user has any of the allowed roles
    return userRoles.any((role) => allowedRoles.contains(role));
  }

  /// Get the appropriate home page for a user based on their roles
  static String getHomePage(List<String> userRoles) {
    if (userRoles.contains('fundi')) return '/fundi-home';
    if (userRoles.contains('customer')) return '/customer-home';
    return '/login';
  }

  /// Get all available pages for a user based on their roles
  static List<String> getAvailablePages(List<String> userRoles) {
    List<String> availablePages = [];
    
    // Customer pages (accessible by both customers and fundis)
    if (userRoles.contains('customer')) {
      availablePages.addAll([
        '/customer-home',
        '/post-job',
        '/browse-fundis',
        '/my-jobs',
        '/rate-fundi',
        '/payment-management',
        '/job-details',
        '/fundi-details',
      ]);
    }
    
    // Fundi pages (only fundis)
    if (userRoles.contains('fundi')) {
      availablePages.addAll([
        '/fundi-home',
        '/job-applications',
        '/my-portfolio',
        '/fundi-profile',
        '/application-status',
        '/portfolio-edit',
        '/fundi-application',
      ]);
    }
    
    // Admin pages removed - mobile app doesn't need admin functionality
    
    // Always available pages
    availablePages.addAll([
      '/profile',
      '/settings',
      '/notifications',
      '/help',
      '/about',
    ]);
    
    return availablePages.toSet().toList(); // Remove duplicates
  }

  /// Check if user has a specific role
  static bool hasRole(List<String> userRoles, String role) {
    return userRoles.contains(role);
  }

  /// Check if user has any of the specified roles
  static bool hasAnyRole(List<String> userRoles, List<String> roles) {
    return roles.any((role) => userRoles.contains(role));
  }

  /// Check if user is a customer (including fundis who are also customers)
  static bool isCustomer(List<String> userRoles) {
    return userRoles.contains('customer');
  }

  /// Check if user is a fundi
  static bool isFundi(List<String> userRoles) {
    return userRoles.contains('fundi');
  }

  /// Get user's primary role for display purposes
  static String getPrimaryRole(List<String> userRoles) {
    if (userRoles.contains('fundi')) return 'fundi';
    if (userRoles.contains('customer')) return 'customer';
    return 'guest';
  }

  /// Check if user can perform action based on payment plan
  /// This is a simplified check - actual payment validation should be done server-side
  static Future<bool> canPerformAction(String action) async {
    try {
      // For now, always allow actions - payment checks should be done server-side
      // In a real implementation, you might want to cache payment plan info locally
      return true;
    } catch (e) {
      // If payment check fails, allow the action and let server handle validation
      return true;
    }
  }

  /// Get payment-required actions
  static List<String> getPaymentRequiredActions() {
    return [
      'post_job',
      'apply_job',
      'message_fundi',
      'browse_fundis',
    ];
  }
}
