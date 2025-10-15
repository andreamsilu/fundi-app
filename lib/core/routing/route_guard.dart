import 'package:flutter/material.dart';
import '../../features/auth/services/auth_service.dart';
import 'app_router.dart';

/// Route guard widget that protects routes based on authentication status
class RouteGuard extends StatelessWidget {
  final Widget child;
  final bool requiresAuth;
  final String? redirectRoute;
  final List<String> allowedRoles;

  const RouteGuard({
    super.key,
    required this.child,
    this.requiresAuth = false,
    this.redirectRoute,
    this.allowedRoles = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Use AuthService directly instead of Provider
    final authService = AuthService();
    final user = authService.currentUser;
    final isAuthenticated = authService.isAuthenticated;

    // Check authentication requirement
    if (requiresAuth && !isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
        ).pushReplacementNamed(redirectRoute ?? AppRouter.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Check role-based access
    if (allowedRoles.isNotEmpty && user != null) {
      final userRole = user.primaryRole;
      if (!allowedRoles.contains(userRole.value)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(AppRouter.dashboard);
        });
        return const Scaffold(body: Center(child: Text('Access denied')));
      }
    }

    return child;
  }
}

/// Specific route guards for different access levels
class AuthGuard extends StatelessWidget {
  final Widget child;
  final String? redirectRoute;

  const AuthGuard({super.key, required this.child, this.redirectRoute});

  @override
  Widget build(BuildContext context) {
    return RouteGuard(
      requiresAuth: true,
      redirectRoute: redirectRoute,
      child: child,
    );
  }
}

class GuestGuard extends StatelessWidget {
  final Widget child;
  final String? redirectRoute;

  const GuestGuard({super.key, required this.child, this.redirectRoute});

  @override
  Widget build(BuildContext context) {
    // Use AuthService directly instead of Provider
    final authService = AuthService();

    if (authService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
        ).pushReplacementNamed(redirectRoute ?? AppRouter.dashboard);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return child;
  }
}

class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;
  final String? redirectRoute;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.redirectRoute,
  });

  @override
  Widget build(BuildContext context) {
    return RouteGuard(
      requiresAuth: true,
      allowedRoles: allowedRoles,
      redirectRoute: redirectRoute,
      child: child,
    );
  }
}
