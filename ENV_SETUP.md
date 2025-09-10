# Environment Variables Setup

## Creating .env File

Create a `.env` file in the root directory of your project with the following variables:

```env
# API Configuration
API_BASE_URL=https://api.fundi.app/v1
API_VERSION=v1
API_TIMEOUT=30000

# Authentication
JWT_SECRET=your_jwt_secret_here
TOKEN_EXPIRY_HOURS=24

# Database
DATABASE_URL=your_database_url_here

# External Services
SMS_API_KEY=your_sms_api_key_here
SMS_SENDER_ID=FUNDI

# File Upload
MAX_FILE_SIZE=5242880
ALLOWED_FILE_TYPES=jpg,jpeg,png,pdf,doc,docx

# Validation
MIN_PASSWORD_LENGTH=6
MAX_NAME_LENGTH=50
MAX_DESCRIPTION_LENGTH=500

# Pagination
DEFAULT_PAGE_SIZE=20
MAX_PAGE_SIZE=100

# App Configuration
APP_NAME=Fundi App
APP_VERSION=1.0.0
DEBUG_MODE=true
```

## Usage

The environment variables are automatically loaded when the app starts and can be accessed through:

```dart
import 'package:fundi_app/core/config/env_config.dart';

// Get a string value
String apiUrl = EnvConfig.get('API_BASE_URL');

// Get an integer value
int timeout = EnvConfig.getInt('API_TIMEOUT');

// Get a boolean value
bool isDebug = EnvConfig.getBool('DEBUG_MODE');
```

## Security Note

- Never commit the `.env` file to version control
- The `.env` file is already added to `.gitignore`
- Use `.env.example` as a template for other developers
