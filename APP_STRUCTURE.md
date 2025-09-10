# App Structure Documentation

## Overview

The Fundi App has been restructured for better organization, maintainability, and separation of concerns. The main app initialization logic has been separated from `main.dart` into dedicated files.

## File Structure

### Core App Files

#### `lib/main.dart`
- **Purpose**: Entry point of the application
- **Responsibilities**:
  - Initialize Flutter binding
  - Initialize app configuration
  - Initialize API client
  - Run the app

#### `lib/core/app/app_initializer.dart`
- **Purpose**: Handles app initialization and routing logic
- **Responsibilities**:
  - Check authentication state
  - Route to appropriate screen (login/dashboard)
  - Show loading screen during initialization
  - Manage app startup flow

#### `lib/core/app/app_config.dart`
- **Purpose**: Centralized app configuration
- **Responsibilities**:
  - Environment variable initialization
  - Provider configuration
  - Theme configuration
  - App metadata (title, version, debug mode)
  - Route configuration

## Architecture Benefits

### 1. **Separation of Concerns**
- `main.dart`: Only handles app startup
- `AppInitializer`: Handles authentication routing
- `AppConfig`: Manages all configuration

### 2. **Better Organization**
- Core app logic is separated from entry point
- Configuration is centralized
- Easy to modify app behavior without touching main.dart

### 3. **Maintainability**
- Each file has a single responsibility
- Easy to test individual components
- Clear file structure for new developers

### 4. **Configuration Management**
- Environment-based configuration
- Centralized provider setup
- Easy theme switching
- Debug mode control

## Usage Examples

### App Initialization
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app configuration
  await AppConfig.initialize();
  
  // Initialize API client
  await ApiClient().initialize();
  
  runApp(const FundiApp());
}
```

### App Configuration
```dart
class FundiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppConfig.providers,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: AppConfig.appTitle,
            debugShowCheckedModeBanner: AppConfig.showDebugBanner,
            theme: AppConfig.lightTheme,
            darkTheme: AppConfig.darkTheme,
            home: AppConfig.homeWidget,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppConfig.initialRoute,
          );
        },
      ),
    );
  }
}
```

### App Initializer
```dart
class AppInitializer extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return LoadingWidget();
        }
        
        if (authProvider.isAuthenticated) {
          return MainDashboard();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
```

## Configuration Options

### Environment Variables
- `APP_NAME`: Application title
- `APP_VERSION`: Application version
- `DEBUG_MODE`: Debug mode flag

### Provider Configuration
- `AuthProvider`: Authentication state
- `JobProvider`: Job-related state
- `PortfolioProvider`: Portfolio state
- `MessagingProvider`: Messaging state

### Theme Configuration
- Light theme: `AppConfig.lightTheme`
- Dark theme: `AppConfig.darkTheme`
- Theme mode: Configurable via environment

## Adding New Features

### 1. Add New Provider
```dart
// In AppConfig.providers
ChangeNotifierProvider(create: (_) => NewProvider()),
```

### 2. Add New Configuration
```dart
// In AppConfig class
static String get newConfig => EnvConfig.get('NEW_CONFIG', defaultValue: 'default');
```

### 3. Modify Initialization
```dart
// In AppConfig.initialize()
static Future<void> initialize() async {
  await EnvConfig.initialize();
  // Add new initialization logic
}
```

## Best Practices

1. **Keep main.dart minimal**: Only app startup logic
2. **Use AppConfig**: For all configuration needs
3. **Separate concerns**: Each file has one responsibility
4. **Environment variables**: Use for configurable values
5. **Provider pattern**: For state management
6. **Documentation**: Keep this file updated

## File Dependencies

```
main.dart
├── AppConfig.initialize()
├── ApiClient.initialize()
└── FundiApp
    ├── AppConfig.providers
    ├── AppConfig.homeWidget (AppInitializer)
    ├── AppRouter.generateRoute
    └── AppConfig.theme

AppInitializer
├── AuthProvider
├── LoginScreen
└── MainDashboard

AppConfig
├── EnvConfig
├── AppTheme
├── AppRouter
└── All Providers
```

This structure provides a clean, maintainable, and scalable foundation for the Fundi App.
