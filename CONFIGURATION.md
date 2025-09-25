# Fundi App Configuration Guide

This guide explains how to configure the Fundi mobile app using environment variables and the `.env` file.

## Environment Configuration

The app uses a centralized configuration system that reads from:
1. `.env` file (highest priority)
2. System environment variables
3. Default values (fallback)

## Creating Your .env File

Create a `.env` file in the root directory of the project with the following variables:

```env
# API Configuration
API_BASE_URL=https://api.fundi.tz/api
API_VERSION=v1
API_TIMEOUT=30000

# Development/Production Environment
ENVIRONMENT=development

# Security Settings
MIN_PASSWORD_LENGTH=6
MAX_NAME_LENGTH=50
MAX_DESCRIPTION_LENGTH=500

# Pagination Settings
DEFAULT_PAGE_SIZE=20
MAX_PAGE_SIZE=100

# File Upload Settings
MAX_FILE_SIZE=5242880
ALLOWED_FILE_TYPES=jpg,jpeg,png,gif

# Debug Settings (for development only)
DEBUG_MODE=true
LOG_LEVEL=info
```

## Configuration Classes

### ApiConfig
Centralized API configuration with validation:
- `baseUrl`: API base URL
- `version`: API version
- `timeout`: Connection timeout
- `isSecure`: HTTPS check
- `validate()`: Configuration validation

### EnvConfig
Environment variable management:
- Loads from `.env` file
- Falls back to system environment variables
- Provides default values
- Type-safe getters for different data types

## Usage Examples

### In Services
```dart
import 'package:fundi/core/config/api_config.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  final int timeout = ApiConfig.timeout;
}
```

### In Widgets
```dart
import 'package:fundi/core/config/env_config.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final apiUrl = EnvConfig.get('API_BASE_URL');
    final isDebug = EnvConfig.getBool('DEBUG_MODE');
    
    return Text('API: $apiUrl, Debug: $isDebug');
  }
}
```

## Environment-Specific Configuration

### Development
```env
API_BASE_URL=http://localhost:8000/api
DEBUG_MODE=true
LOG_LEVEL=debug
```

### Production
```env
API_BASE_URL=https://api.fundi.tz/api
DEBUG_MODE=false
LOG_LEVEL=error
```

### Testing
```env
API_BASE_URL=https://test-api.fundi.tz/api
DEBUG_MODE=true
LOG_LEVEL=info
```

## Security Considerations

1. **Never commit `.env` files** to version control
2. **Use HTTPS** in production environments
3. **Validate URLs** before making API calls
4. **Use secure storage** for sensitive data

## Troubleshooting

### Common Issues

1. **Configuration not loading**
   - Ensure `.env` file is in the project root
   - Check file permissions
   - Verify file format (no spaces around `=`)

2. **API connection issues**
   - Verify `API_BASE_URL` is correct
   - Check network connectivity
   - Validate SSL certificates

3. **Environment variables not working**
   - Restart the app after changing `.env`
   - Check for typos in variable names
   - Ensure proper initialization in `main.dart`

### Debug Information

Add this to your app to see current configuration:

```dart
import 'package:fundi/core/config/api_config.dart';

// Print debug information
print('API Config: ${ApiConfig.getDebugInfo()}');
```

## Best Practices

1. **Use environment-specific `.env` files**
2. **Document all configuration options**
3. **Validate configuration on startup**
4. **Provide sensible defaults**
5. **Use type-safe getters**
6. **Handle configuration errors gracefully**

## Migration from Hardcoded Values

The app has been updated to remove hardcoded URLs and endpoints:

- ✅ `ApiConfig` centralizes API configuration
- ✅ `EnvConfig` handles environment variables
- ✅ `.env` file support added
- ✅ Default values updated to production URLs
- ✅ Configuration validation added

All hardcoded values have been replaced with configurable options that can be overridden via environment variables.
