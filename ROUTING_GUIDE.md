# Flutter Routing System Guide

## Overview

The Fundi App uses a centralized routing system with custom navigation, route guards, and type-safe argument passing. This guide explains how routing is mapped and customized.

## Architecture

### 1. **AppRouter** (`lib/core/routing/app_router.dart`)
Central routing configuration that handles:
- Route definitions and constants
- Route generation with custom transitions
- Navigation helper methods
- Route guards and authentication checks
- Type-safe argument classes

### 2. **Route Guards** (`lib/core/routing/route_guard.dart`)
Protection mechanisms for different access levels:
- `RouteGuard`: Base guard with authentication and role checks
- `AuthGuard`: Protects authenticated-only routes
- `GuestGuard`: Protects guest-only routes (login, register)
- `RoleGuard`: Protects routes based on user roles

## Route Mapping

### Route Constants
```dart
class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String newPassword = '/new-password';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String home = '/';
}
```

### Route Generation
Routes are generated using `onGenerateRoute` instead of static `routes`:

```dart
MaterialApp(
  onGenerateRoute: AppRouter.generateRoute,
  initialRoute: AppRouter.home,
)
```

## Navigation Methods

### 1. **Basic Navigation**
```dart
// Navigate to a route
AppRouter.pushNamed(context, AppRouter.dashboard);

// Navigate with arguments
AppRouter.pushNamed(
  context, 
  AppRouter.otpVerification,
  arguments: OtpVerificationArgs(
    phoneNumber: '+255123456789',
    type: OtpVerificationType.registration,
  ).toMap(),
);
```

### 2. **Replacement Navigation**
```dart
// Replace current route
AppRouter.pushReplacementNamed(context, AppRouter.dashboard);

// Replace with arguments
AppRouter.pushReplacementNamed(
  context, 
  AppRouter.login,
  arguments: {'message': 'Please login again'},
);
```

### 3. **Clear Stack Navigation**
```dart
// Clear all previous routes and navigate
AppRouter.navigateAndClearStack(context, AppRouter.dashboard);
```

### 4. **Protected Navigation**
```dart
// Navigate with authentication check
AppRouter.pushNamedWithAuth(
  context, 
  AppRouter.profile,
  redirectRoute: AppRouter.login, // Redirect if not authenticated
);
```

## Route Guards

### 1. **Authentication Guard**
```dart
AuthGuard(
  child: ProfileScreen(),
  redirectRoute: AppRouter.login,
)
```

### 2. **Guest Guard**
```dart
GuestGuard(
  child: LoginScreen(),
  redirectRoute: AppRouter.dashboard,
)
```

### 3. **Role-Based Guard**
```dart
RoleGuard(
  allowedRoles: ['admin', 'moderator'],
  child: AdminPanel(),
  redirectRoute: AppRouter.dashboard,
)
```

## Custom Transitions

### Slide Transition (Default)
All routes use a custom slide transition:
```dart
static Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
```

## Type-Safe Arguments

### Argument Classes
```dart
class OtpVerificationArgs {
  final String phoneNumber;
  final OtpVerificationType type;
  final String? userId;

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'type': type,
      'userId': userId,
    };
  }
}
```

### Usage
```dart
// Navigate with type-safe arguments
final args = OtpVerificationArgs(
  phoneNumber: '+255123456789',
  type: OtpVerificationType.registration,
);

AppRouter.pushNamed(
  context, 
  AppRouter.otpVerification,
  arguments: args.toMap(),
);
```

## Route Protection

### Authentication Checks
```dart
static bool canAccessRoute(BuildContext context, String routeName) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  const protectedRoutes = [AppRouter.dashboard, AppRouter.profile];
  const authOnlyRoutes = [AppRouter.login, AppRouter.register];
  
  if (protectedRoutes.contains(routeName)) {
    return authProvider.isAuthenticated;
  }
  
  if (authOnlyRoutes.contains(routeName)) {
    return !authProvider.isAuthenticated;
  }
  
  return true;
}
```

## Customization Options

### 1. **Add New Routes**
```dart
// In AppRouter class
static const String newRoute = '/new-route';

// In generateRoute method
case newRoute:
  return _buildRoute(const NewScreen(), settings);
```

### 2. **Custom Transitions**
```dart
static Route<dynamic> _buildCustomRoute(Widget page, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Custom transition logic
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
```

### 3. **Add Route Guards**
```dart
// In RouteGuard class
class CustomGuard extends StatelessWidget {
  final Widget child;
  final String customCondition;

  const CustomGuard({
    super.key,
    required this.child,
    required this.customCondition,
  });

  @override
  Widget build(BuildContext context) {
    // Custom guard logic
    if (customCondition == 'special') {
      return child;
    }
    return const AccessDeniedScreen();
  }
}
```

## Best Practices

1. **Use Route Constants**: Always use `AppRouter.routeName` instead of hardcoded strings
2. **Type-Safe Arguments**: Use argument classes for complex data passing
3. **Route Guards**: Protect sensitive routes with appropriate guards
4. **Consistent Navigation**: Use `AppRouter` methods for all navigation
5. **Error Handling**: Handle route not found cases gracefully
6. **Performance**: Use `pushReplacementNamed` for login/logout flows
7. **Deep Linking**: Consider URL-based routing for web support

## Example Usage in Screens

```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Login form
          ElevatedButton(
            onPressed: () {
              // Navigate to dashboard after successful login
              AppRouter.navigateAndClearStack(context, AppRouter.dashboard);
            },
            child: Text('Login'),
          ),
          TextButton(
            onPressed: () {
              // Navigate to register
              AppRouter.pushNamed(context, AppRouter.register);
            },
            child: Text('Register'),
          ),
        ],
      ),
    );
  }
}
```

This routing system provides a robust, scalable, and maintainable navigation solution for the Fundi App.
