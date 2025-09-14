# Provider Configuration Guide

## Overview
This guide documents the complete provider setup for the Fundi App, ensuring all screens have access to their required providers.

## Provider Registration

### Main Provider Setup
All providers are registered in `lib/core/providers/lazy_provider_manager.dart` and loaded in `lib/main.dart`:

```dart
// All providers are registered with lazy loading for performance
final providers = LazyProviderManager.getProviders();
return MultiProvider(providers: providers, child: MaterialApp(...));
```

### Registered Providers

#### 1. **AuthProvider** (Critical - Non-lazy)
- **Purpose**: User authentication and session management
- **Used by**: All screens that need user context
- **Initialization**: Immediate (lazy: false)
- **Screens**: MainDashboard, FundiApplicationScreen, ChatScreen, SettingsScreen, etc.

#### 2. **FeedsProvider** (Lazy)
- **Purpose**: Manage fundis and jobs feeds data
- **Used by**: FundiFeedScreen, JobFeedScreen
- **Initialization**: Lazy (lazy: true)
- **Fallback Logic**: ✅ Implemented in FundiFeedScreen

#### 3. **JobProvider** (Lazy)
- **Purpose**: Job management and operations
- **Used by**: JobListScreen, JobDetailsScreen
- **Initialization**: Lazy (lazy: true)

#### 4. **PortfolioProvider** (Lazy)
- **Purpose**: Portfolio management for fundis
- **Used by**: PortfolioScreen, PortfolioDetailsScreen
- **Initialization**: Lazy (lazy: true)
- **Fallback Logic**: ✅ Implemented in PortfolioScreen

#### 5. **MessagingProvider** (Lazy)
- **Purpose**: Chat and messaging functionality
- **Used by**: ChatScreen, ChatListScreen
- **Initialization**: Lazy (lazy: true)

#### 6. **SearchProvider** (Lazy)
- **Purpose**: Search functionality across the app
- **Used by**: Search screens
- **Initialization**: Lazy (lazy: true)

#### 7. **NotificationProvider** (Lazy)
- **Purpose**: Push notifications and in-app notifications
- **Used by**: NotificationsScreen
- **Initialization**: Lazy (lazy: true)

#### 8. **SettingsProvider** (Lazy)
- **Purpose**: App settings and preferences
- **Used by**: SettingsScreen
- **Initialization**: Lazy (lazy: true)

#### 9. **PaymentProvider** (Lazy) - ✅ Recently Added
- **Purpose**: Payment processing and transaction management
- **Used by**: PaymentFlowScreen, PaymentFormScreen, PaymentListScreen
- **Initialization**: Lazy (lazy: true)

#### 10. **RatingProvider** (Lazy) - ✅ Recently Added
- **Purpose**: Rating and review management
- **Used by**: RatingListScreen, RatingFormScreen
- **Initialization**: Lazy (lazy: true)

#### 11. **WorkApprovalProvider** (Lazy)
- **Purpose**: Work approval workflow management
- **Used by**: WorkApprovalScreen
- **Initialization**: Lazy (lazy: true)

## Provider Fallback Logic

### Screens with Fallback Logic
Some screens implement fallback logic to handle cases where providers might not be available:

#### 1. **FundiFeedScreen**
```dart
Widget _buildBody() {
  try {
    Provider.of<FeedsProvider>(context, listen: false);
    return Consumer<FeedsProvider>(...);
  } catch (e) {
    // Create local provider if not available
    return ChangeNotifierProvider(
      create: (_) => FeedsProvider()..loadFundis(),
      child: Consumer<FeedsProvider>(...),
    );
  }
}
```

#### 2. **PortfolioScreen**
```dart
Widget _buildPortfolioBody() {
  try {
    Provider.of<PortfolioProvider>(context, listen: false);
    return Consumer<PortfolioProvider>(...);
  } catch (e) {
    // Create local provider if not available
    return ChangeNotifierProvider(
      create: (_) => PortfolioProvider()..loadPortfolios(),
      child: Consumer<PortfolioProvider>(...),
    );
  }
}
```

## Provider Usage Patterns

### 1. **Safe Provider Access**
```dart
// In initState or methods
try {
  final provider = Provider.of<SomeProvider>(context, listen: false);
  provider.someMethod();
} catch (e) {
  print('Provider not available: $e');
  // Handle gracefully
}
```

### 2. **Consumer Pattern**
```dart
// In build method
Consumer<SomeProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return LoadingWidget();
    if (provider.error != null) return ErrorWidget();
    return ContentWidget();
  },
)
```

### 3. **Context Read Pattern**
```dart
// For one-time access
final provider = context.read<SomeProvider>();
provider.performAction();
```

## Navigation and Provider Access

### Bottom Navigation Screens
- All screens in bottom navigation have access to global providers
- No additional provider setup needed

### Drawer Navigation Screens
- All screens accessible via drawer have access to global providers
- No additional provider setup needed

### Modal/Overlay Screens
- Screens opened via `Navigator.push` inherit provider context
- No additional provider setup needed

## Best Practices

### 1. **Provider Initialization**
- Use lazy loading for non-critical providers
- Initialize AuthProvider immediately for user context
- Preload providers when needed

### 2. **Error Handling**
- Always wrap `Provider.of` calls in try-catch
- Implement fallback logic for critical screens
- Provide meaningful error messages

### 3. **Performance**
- Use `listen: false` when you don't need to rebuild
- Use `Consumer` only when you need to rebuild on changes
- Avoid unnecessary provider lookups

### 4. **Testing**
- Mock providers for unit tests
- Test provider fallback logic
- Verify provider availability in integration tests

## Troubleshooting

### Common Issues

#### 1. **"Could not find the correct Provider" Error**
- **Cause**: Provider not available in widget tree
- **Solution**: Check if provider is registered in LazyProviderManager
- **Fallback**: Implement fallback logic in screen

#### 2. **Provider Not Updating UI**
- **Cause**: Using `Provider.of` with `listen: false` in build method
- **Solution**: Use `Consumer` widget or `Provider.of` with `listen: true`

#### 3. **Provider State Lost on Navigation**
- **Cause**: Provider created locally instead of globally
- **Solution**: Ensure provider is registered globally in LazyProviderManager

### Debug Commands
```dart
// Check if provider exists
try {
  Provider.of<SomeProvider>(context, listen: false);
  print('Provider available');
} catch (e) {
  print('Provider not available: $e');
}

// List all available providers
final providers = LazyProviderManager.getProviders();
print('Available providers: ${providers.length}');
```

## Conclusion

The Fundi App now has a comprehensive provider setup with:
- ✅ All 11 providers properly registered
- ✅ Lazy loading for performance
- ✅ Fallback logic for critical screens
- ✅ Consistent error handling
- ✅ Proper navigation support

All screens should now work correctly with their respective providers, whether accessed via bottom navigation, drawer navigation, or modal presentation.
