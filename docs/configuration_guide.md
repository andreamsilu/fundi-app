# Configuration Guide for JWT Integration

## Environment Configuration

Create a `.env` file in the root directory of the Flutter app with the following content:

```env
# JWT API Configuration
API_BASE_URL=http://localhost:8000/api
API_VERSION=v1
API_TIMEOUT=30000

# Environment
ENVIRONMENT=development

# App Configuration
MIN_PASSWORD_LENGTH=6
MAX_NAME_LENGTH=50
MAX_DESCRIPTION_LENGTH=500
DEFAULT_PAGE_SIZE=20
MAX_PAGE_SIZE=100
MAX_FILE_SIZE=5242880
ALLOWED_FILE_TYPES=jpg,jpeg,png,gif
```

## API Configuration

### Base URL
- **Development**: `http://localhost:8000/api`
- **Production**: Update to your production API URL

### Endpoints
- **Login**: `POST /auth/login`
- **Register**: `POST /auth/register`
- **Logout**: `POST /auth/logout`
- **Refresh**: `POST /auth/refresh`
- **User Profile**: `GET /users/me`

## Testing Configuration

### Test Users
The following test users are available in the JWT API:

1. **Admin User**
   - Phone: `0754289824`
   - Password: `password123`
   - Role: `admin`

2. **Customer User**
   - Phone: `0654289825`
   - Password: `password123`
   - Role: `customer`

3. **Fundi User**
   - Phone: `0654289827`
   - Password: `password123`
   - Role: `fundi`

### Test API Endpoints
- **Health Check**: `GET /health`
- **Job Feeds**: `GET /feeds/jobs`
- **User Profile**: `GET /users/me`

## Dependencies

Make sure to run `flutter pub get` after updating `pubspec.yaml` to install the JWT decoder package:

```bash
flutter pub get
```

## Running the Tests

To test the JWT integration, run the test file:

```bash
dart test_jwt_integration.dart
```

## Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Check if the Laravel API is running on `http://localhost:8000`
   - Verify the API base URL in `.env` file

2. **JWT Token Issues**
   - Ensure the JWT package is installed: `flutter pub get`
   - Check token format and expiration

3. **Authentication Failed**
   - Verify test user credentials
   - Check if user has proper roles assigned

### Debug Information

Enable debug logging by checking the console output for:
- API request/response logs
- JWT token information
- Authentication status
- Error messages

## Next Steps

1. **Install Dependencies**: Run `flutter pub get`
2. **Configure Environment**: Create `.env` file with correct API URL
3. **Test Integration**: Run the test file to verify JWT integration
4. **Update UI**: Modify login/registration screens to use JWT authentication
5. **Test User Flows**: Test complete user authentication flows
