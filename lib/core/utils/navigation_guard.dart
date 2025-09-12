import 'package:flutter/material.dart';

/// Navigation guard to prevent app stacking
class NavigationGuard {
  static final NavigationGuard _instance = NavigationGuard._internal();
  factory NavigationGuard() => _instance;
  NavigationGuard._internal();

  bool _isNavigating = false;
  String? _currentRoute;

  /// Check if navigation is in progress
  bool get isNavigating => _isNavigating;

  /// Get current route
  String? get currentRoute => _currentRoute;

  /// Start navigation
  void startNavigation(String route) {
    _isNavigating = true;
    _currentRoute = route;
  }

  /// End navigation
  void endNavigation() {
    _isNavigating = false;
    _currentRoute = null;
  }

  /// Check if route is already active
  bool isRouteActive(String route) {
    return _currentRoute == route;
  }

  /// Safe navigation that prevents stacking
  Future<T?> safePush<T extends Object?>(
    BuildContext context,
    Route<T> route,
  ) async {
    if (_isNavigating) {
      return null;
    }

    _startNavigation(route.settings.name ?? 'unknown');

    try {
      final result = await Navigator.push<T>(context, route);
      return result;
    } finally {
      _endNavigation();
    }
  }

  /// Safe navigation replacement
  Future<T?> safePushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Route<T> route, {
    TO? result,
  }) async {
    if (_isNavigating) {
      return null;
    }

    _startNavigation(route.settings.name ?? 'unknown');

    try {
      final navigationResult = await Navigator.pushReplacement<T, TO>(
        context,
        route,
        result: result,
      );
      return navigationResult;
    } finally {
      _endNavigation();
    }
  }

  /// Safe navigation with named route
  Future<T?> safePushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    if (_isNavigating || isRouteActive(routeName)) {
      return null;
    }

    _startNavigation(routeName);

    try {
      final result = await Navigator.pushNamed<T>(
        context,
        routeName,
        arguments: arguments,
      );
      return result;
    } finally {
      _endNavigation();
    }
  }

  /// Safe navigation replacement with named route
  Future<T?> safePushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) async {
    if (_isNavigating) {
      return null;
    }

    _startNavigation(routeName);

    try {
      final navigationResult = await Navigator.pushReplacementNamed<T, TO>(
        context,
        routeName,
        arguments: arguments,
        result: result,
      );
      return navigationResult;
    } finally {
      _endNavigation();
    }
  }

  void _startNavigation(String route) {
    _isNavigating = true;
    _currentRoute = route;
  }

  void _endNavigation() {
    _isNavigating = false;
    _currentRoute = null;
  }

  /// Reset navigation state
  void reset() {
    _isNavigating = false;
    _currentRoute = null;
  }
}
