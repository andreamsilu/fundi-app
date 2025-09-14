# App Flow Sequence - Splash → Onboarding → Login

## Current Implementation

The app now follows this optimized sequence:

### 1. **Splash Screen** (2 seconds)
- **File**: `lib/core/app/splash_screen.dart`
- **Duration**: 2 seconds minimum
- **Purpose**: Show branded loading screen while background initialization happens
- **Features**:
  - Animated logo with fade and scale effects
  - App branding and tagline
  - Loading indicator
  - Smooth 60fps animations

### 2. **Onboarding Screen** (if not completed)
- **File**: `lib/features/onboarding/screens/onboarding_screen.dart`
- **Condition**: Only shown if user hasn't completed onboarding
- **Purpose**: Guide new users through app features
- **Features**:
  - Interactive onboarding slides
  - Skip option for returning users
  - Progress indicators

### 3. **Login Screen** (if not authenticated)
- **File**: `lib/features/auth/screens/login_screen.dart`
- **Condition**: Only shown if user is not authenticated
- **Purpose**: User authentication
- **Features**:
  - Phone number and password input
  - Registration option
  - Forgot password functionality

### 4. **Main Dashboard** (if authenticated)
- **File**: `lib/features/dashboard/screens/main_dashboard.dart`
- **Condition**: Only shown if user is authenticated
- **Purpose**: Main app interface
- **Features**:
  - Role-based navigation
  - Job listings and portfolio management
  - User profile and settings

## Flow Control Logic

```dart
// In AppInitializer
@override
Widget build(BuildContext context) {
  // 1. Show splash screen first
  if (_showSplash) {
    return const SplashScreen();
  }

  // 2. Show loading while checking onboarding
  if (_isCheckingOnboarding) {
    return const LoadingWidget();
  }

  // 3. Show onboarding if not completed
  if (!_hasCompletedOnboarding) {
    return const OnboardingScreen();
  }

  // 4. Show login or dashboard based on auth status
  return Consumer<AuthProvider>(
    builder: (context, authProvider, child) {
      if (authProvider.isAuthenticated) {
        return const MainDashboard();
      } else {
        return const LoginScreen();
      }
    },
  );
}
```

## Timing Sequence

```
App Start
    ↓
Splash Screen (2s)
    ↓
Check Onboarding Status
    ↓
┌─ Not Completed → Onboarding Screen
└─ Completed → Check Auth Status
    ↓
┌─ Authenticated → Main Dashboard
└─ Not Authenticated → Login Screen
```

## Performance Benefits

1. **Immediate Visual Feedback**: Splash screen shows instantly
2. **Background Initialization**: Heavy work happens during splash
3. **Smooth Transitions**: No jarring screen changes
4. **User Experience**: Clear progression through app states
5. **Memory Efficient**: Only necessary screens are loaded

## Testing the Flow

To test the complete flow sequence:

1. **Fresh Install**: Shows Splash → Onboarding → Login
2. **Returning User (No Auth)**: Shows Splash → Login
3. **Authenticated User**: Shows Splash → Dashboard
4. **Onboarding Completed**: Skips onboarding step

## Customization Options

### Splash Screen Duration
```dart
// In app_initializer.dart
await Future.delayed(const Duration(seconds: 2)); // Adjust as needed
```

### Animation Duration
```dart
// In splash_screen.dart
_animationController = AnimationController(
  duration: const Duration(milliseconds: 2000), // Adjust as needed
  vsync: this,
);
```

### Background Initialization
```dart
// In app_initialization_service.dart
// Heavy initialization happens during splash screen
AppInitializationService.initializeAsync();
```

## Debug Mode

In debug mode, you can see the flow progression in the console:
```
🚀 Startup Milestone: app_start at 1234567890ms
🚀 Startup Milestone: flutter_binding_initialized at 1234567891ms
🚀 Startup Milestone: app_config_initialized at 1234567892ms
🚀 Startup Milestone: background_init_started at 1234567893ms
🚀 Startup Milestone: runapp_called at 1234567894ms
```

This ensures the app flow is working correctly and provides a smooth user experience from launch to the main interface.

