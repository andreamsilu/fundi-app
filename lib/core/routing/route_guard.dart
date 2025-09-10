import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Check authentication requirement
        if (requiresAuth && !authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(
              context,
            ).pushReplacementNamed(redirectRoute ?? AppRouter.login);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check role-based access
        if (allowedRoles.isNotEmpty && authProvider.user != null) {
          final userRole = authProvider.user!.role;
          if (!allowedRoles.contains(userRole.value)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(AppRouter.dashboard);
            });
            return const Scaffold(body: Center(child: Text('Access denied')));
          }
        }

        return child;
      },
    );
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(
              context,
            ).pushReplacementNamed(redirectRoute ?? AppRouter.dashboard);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return child;
      },
    );
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
