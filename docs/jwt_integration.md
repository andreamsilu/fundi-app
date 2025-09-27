# JWT Authentication Integration

This document explains how the Flutter app has been configured to use JWT (JSON Web Token) authentication with the Laravel API.

## Overview

The Flutter app has been updated to work with the JWT authentication system implemented in the Laravel API. This includes:

- JWT token handling and validation
- Automatic token refresh
- Role-based authentication
- Secure token storage

## Key Changes Made

### 1. AuthService Updates

**File:** `lib/features/auth/services/auth_service.dart`

- Updated login method to handle JWT API response structure
- Added JWT token refresh functionality
- Updated registration to handle JWT response format
- Enhanced error handling for JWT-specific errors

**Key Changes:**
```dart
// Extract token and user data from the JWT API response structure
final token = responseData['access_token'] as String;
final userData = responseData['user'] as Map<String, dynamic>;
```

### 2. UserModel Updates

**File:** `lib/features/auth/models/user_model.dart`

- Enhanced JSON parsing to handle JWT API response structure
- Added support for roles and permissions from JWT payload
- Improved role handling for multiple user types
- Added fallback mechanisms for role parsing

**Key Features:**
- Handles both `roles` array and `role_names` array
- Supports role IDs for efficient API operations
- Maintains backward compatibility

### 3. API Client Updates

**File:** `lib/core/network/api_client.dart`

- Added JWT token validation before requests
- Enhanced authentication interceptor for JWT tokens
- Improved error handling for token expiration
- Added automatic session clearing on token invalidation

### 4. JWT Token Manager

**File:** `lib/core/services/jwt_token_manager.dart` (NEW)

- JWT token validation and expiration checking
- Token payload extraction
- User ID and roles extraction from token
- Token refresh logic
- Comprehensive token information for debugging

**Key Methods:**
- `isTokenValid()` - Check if token is valid and not expired
- `isTokenExpired()` - Check if token is expired
- `getTokenPayload()` - Extract token payload
- `getUserIdFromToken()` - Get user ID from token
- `getUserRolesFromToken()` - Get user roles from token
- `needsRefresh()` - Check if token needs refresh

### 5. API Endpoints Updates

**File:** `lib/core/constants/api_endpoints.dart`

- Added JWT refresh endpoint
- Updated authentication endpoints to match JWT API
- Added comments for JWT-specific endpoints

### 6. Environment Configuration

**File:** `lib/core/config/env_config.dart`

- Updated default API URL to point to local JWT API
- Added JWT-specific configuration options

### 7. Dependencies

**File:** `pubspec.yaml`

- Added `jwt_decoder: ^2.0.1` for JWT token handling

## JWT API Response Structure

The Flutter app now expects the following JWT API response structure:

### Login Response
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "token_type": "bearer",
    "expires_in": 3600,
    "user": {
      "id": 1,
      "phone": "0754289824",
      "full_name": "Admin User",
      "email": "admin@fundi.com",
      "status": "active",
      "roles": [
        {
          "id": 3,
          "name": "admin",
          "guard_name": "api"
        }
      ],
      "permissions": [...],
      "role_names": ["admin"],
      "permission_names": [...],
      "is_admin": true,
      "is_customer": false,
      "is_fundi": false
    }
  }
}
```

### User Profile Response
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "phone": "0754289824",
      "full_name": "Admin User",
      "roles": [...],
      "permissions": [...],
      "role_names": ["admin"],
      "permission_names": [...],
      "is_admin": true,
      "is_customer": false,
      "is_fundi": false
    }
  }
}
```

## Authentication Flow

1. **Login**: User provides phone and password
2. **JWT Token**: API returns JWT token with user data
3. **Token Storage**: Token is stored securely in session manager
4. **API Requests**: Token is automatically added to request headers
5. **Token Validation**: Token is validated before each request
6. **Token Refresh**: Token is refreshed when needed
7. **Logout**: Token is cleared from storage

## Security Features

- **Token Validation**: JWT tokens are validated before use
- **Automatic Expiration**: Expired tokens are automatically cleared
- **Secure Storage**: Tokens are stored using secure storage mechanisms
- **Role-Based Access**: User roles are extracted from JWT payload
- **Permission Checking**: User permissions are available from JWT

## Testing

A comprehensive test file has been created at `test_jwt_integration.dart` that tests:

- Environment configuration
- API client initialization
- JWT login flow
- Token validation
- API calls with JWT authentication
- Logout functionality

## Usage Examples

### Login with JWT
```dart
final authService = AuthService();
final result = await authService.login(
  phoneNumber: '0754289824',
  password: 'password123',
);

if (result.success) {
  print('User: ${result.user?.displayName}');
  print('Roles: ${result.user?.roles.map((r) => r.value).join(', ')}');
}
```

### Check Token Status
```dart
final jwtManager = JwtTokenManager();
final tokenInfo = jwtManager.getTokenInfo();
print('Token valid: ${tokenInfo['isValid']}');
print('Expires in: ${tokenInfo['timeUntilExpiry']} minutes');
```

### Make Authenticated API Call
```dart
final apiClient = ApiClient();
final response = await apiClient.get<Map<String, dynamic>>(
  '/users/me',
  fromJson: (data) => data as Map<String, dynamic>,
);
```

## Configuration

### Environment Variables
```env
API_BASE_URL=http://localhost:8000/api
API_VERSION=v1
API_TIMEOUT=30000
```

### API Endpoints
- Login: `POST /auth/login`
- Register: `POST /auth/register`
- Logout: `POST /auth/logout`
- Refresh: `POST /auth/refresh`
- User Profile: `GET /users/me`

## Troubleshooting

### Common Issues

1. **Token Expired**: Check if JWT token is expired using `JwtTokenManager`
2. **Invalid Token**: Ensure token is properly formatted and not corrupted
3. **API Connection**: Verify API base URL is correct
4. **Role Parsing**: Check if user roles are properly parsed from JWT payload

### Debug Information

Use the JWT token manager to get debug information:
```dart
final jwtManager = JwtTokenManager();
final tokenInfo = jwtManager.getTokenInfo();
print('Debug info: $tokenInfo');
```

## Migration Notes

- The app now uses JWT tokens instead of session-based authentication
- User roles are extracted from JWT payload
- Token refresh is handled automatically
- All API calls now include JWT authentication headers

## Future Enhancements

- Implement automatic token refresh
- Add token refresh retry logic
- Enhance security with token rotation
- Add offline token validation
