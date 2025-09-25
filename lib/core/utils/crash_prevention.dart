import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Crash prevention utility to handle common app crashes
class CrashPrevention {
  static final CrashPrevention _instance = CrashPrevention._internal();
  factory CrashPrevention() => _instance;
  CrashPrevention._internal();

  /// Safe provider access with fallback
  static T? safeProviderAccess<T>(BuildContext context, {bool listen = false}) {
    try {
      return Provider.of<T>(context, listen: listen);
    } catch (e) {
      print('Provider not available: $e');
      return null;
    }
  }

  /// Safe navigation with error handling
  static Future<void> safeNavigate(
    BuildContext context,
    String routeName, {
    Object? arguments,
    Widget? fallbackScreen,
  }) async {
    try {
      await Navigator.pushNamed(context, routeName, arguments: arguments);
    } catch (e) {
      print('Navigation error: $e');
      if (fallbackScreen != null && context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => fallbackScreen),
        );
      }
    }
  }

  /// Safe navigation with MaterialPageRoute
  static Future<void> safeNavigateTo(
    BuildContext context,
    Widget screen, {
    Widget? fallbackScreen,
  }) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    } catch (e) {
      print('Navigation error: $e');
      if (fallbackScreen != null && context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => fallbackScreen),
        );
      }
    }
  }

  /// Safe null check with default value
  static T safeNullCheck<T>(T? value, T defaultValue) {
    return value ?? defaultValue;
  }

  /// Safe string operations
  static String safeString(String? value, {String defaultValue = ''}) {
    return value ?? defaultValue;
  }

  /// Safe int operations
  static int safeInt(int? value, {int defaultValue = 0}) {
    return value ?? defaultValue;
  }

  /// Safe bool operations
  static bool safeBool(bool? value, {bool defaultValue = false}) {
    return value ?? defaultValue;
  }

  /// Safe list operations
  static List<T> safeList<T>(
    List<T>? value, {
    List<T> defaultValue = const [],
  }) {
    return value ?? defaultValue;
  }

  /// Safe map operations
  static Map<K, V> safeMap<K, V>(
    Map<K, V>? value, {
    Map<K, V> defaultValue = const {},
  }) {
    return value ?? defaultValue;
  }

  /// Check if context is mounted
  static bool isContextMounted(BuildContext context) {
    try {
      return context.mounted;
    } catch (e) {
      return false;
    }
  }

  /// Safe widget building with error boundary
  static Widget safeBuild(
    BuildContext context,
    Widget Function() builder, {
    Widget? errorWidget,
  }) {
    try {
      return builder();
    } catch (e) {
      print('Widget build error: $e');
      return errorWidget ??
          const Scaffold(
            body: Center(
              child: Text('Something went wrong. Please try again.'),
            ),
          );
    }
  }

  /// Safe async operations
  static Future<T?> safeAsync<T>(
    Future<T> Function() operation, {
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } catch (e) {
      print('Async operation error: $e');
      return fallbackValue;
    }
  }

  /// Safe provider consumer with fallback
  static Widget safeConsumer<T>(
    BuildContext context,
    Widget Function(BuildContext context, T provider, Widget? child) builder, {
    Widget? fallbackWidget,
    Widget? child,
  }) {
    try {
      Provider.of<T>(context, listen: false);
      return Consumer<T>(builder: builder, child: child);
    } catch (e) {
      print('Provider consumer error: $e');
      return fallbackWidget ?? const SizedBox.shrink();
    }
  }

  /// Safe provider consumer with local provider fallback
  static Widget safeConsumerWithFallback<T extends ChangeNotifier>(
    BuildContext context,
    Widget Function(BuildContext context, T provider, Widget? child) builder,
    T Function() fallbackProvider, {
    Widget? child,
  }) {
    try {
      Provider.of<T>(context, listen: false);
      return Consumer<T>(builder: builder, child: child);
    } catch (e) {
      print('Provider not available, creating local provider: $e');
      return ChangeNotifierProvider<T>(
        create: (_) => fallbackProvider(),
        child: Consumer<T>(builder: builder, child: child),
      );
    }
  }

  /// Safe navigation with route validation
  static Future<void> safeNavigateWithValidation(
    BuildContext context,
    String routeName, {
    Object? arguments,
    Widget? fallbackScreen,
    bool Function(String)? routeValidator,
  }) async {
    // Validate route if validator provided
    if (routeValidator != null && !routeValidator(routeName)) {
      print('Invalid route: $routeName');
      if (fallbackScreen != null && context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => fallbackScreen),
        );
      }
      return;
    }

    // Safe navigation
    await safeNavigate(
      context,
      routeName,
      arguments: arguments,
      fallbackScreen: fallbackScreen,
    );
  }

  /// Safe context operations
  static void safeContextOperation(
    BuildContext context,
    VoidCallback operation, {
    VoidCallback? onError,
  }) {
    try {
      if (context.mounted) {
        operation();
      }
    } catch (e) {
      print('Context operation error: $e');
      onError?.call();
    }
  }

  /// Safe provider operations
  static void safeProviderOperation<T>(
    BuildContext context,
    void Function(T provider) operation, {
    VoidCallback? onError,
  }) {
    try {
      final provider = Provider.of<T>(context, listen: false);
      operation(provider);
    } catch (e) {
      print('Provider operation error: $e');
      onError?.call();
    }
  }

  /// Safe provider operations with fallback
  static void safeProviderOperationWithFallback<T>(
    BuildContext context,
    void Function(T provider) operation,
    T Function() fallbackProvider, {
    VoidCallback? onError,
  }) {
    try {
      final provider = Provider.of<T>(context, listen: false);
      operation(provider);
    } catch (e) {
      print('Provider not available, using fallback: $e');
      try {
        final fallback = fallbackProvider();
        operation(fallback);
      } catch (fallbackError) {
        print('Fallback provider error: $fallbackError');
        onError?.call();
      }
    }
  }

  /// Safe widget disposal
  static void safeDispose(List<dynamic> disposables) {
    for (final disposable in disposables) {
      try {
        if (disposable is AnimationController) {
          disposable.dispose();
        } else if (disposable is TextEditingController) {
          disposable.dispose();
        } else if (disposable is ScrollController) {
          disposable.dispose();
        } else if (disposable is FocusNode) {
          disposable.dispose();
        } else if (disposable is ChangeNotifier) {
          disposable.dispose();
        }
      } catch (e) {
        print('Disposal error: $e');
      }
    }
  }

  /// Safe state management
  static void safeSetState(State state, VoidCallback fn) {
    try {
      if (state.mounted) {
        state.setState(fn);
      }
    } catch (e) {
      print('SetState error: $e');
    }
  }

  /// Safe async state management
  static void safeAsyncSetState(State state, Future<void> Function() fn) {
    try {
      if (state.mounted) {
        fn()
            .then((_) {
              if (state.mounted) {
                state.setState(() {});
              }
            })
            .catchError((e) {
              print('Async setState error: $e');
            });
      }
    } catch (e) {
      print('Async setState error: $e');
    }
  }
}
