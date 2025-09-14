# Fundi App API Documentation

## Overview
This document provides comprehensive documentation for the Fundi App API endpoints and services.

## Base URL
```
http://88.223.92.135:8002/api
```

## Authentication
All API requests require authentication via Bearer token in the Authorization header:
```
Authorization: Bearer <token>
```

## API Endpoints

### Authentication Endpoints

#### POST /auth/login
**Description:** User login with phone and password
**Request Body:**
```json
{
  "phone": "+255712345678",
  "password": "password123"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "id": "10",
    "phone": "+255712345678",
    "roles": ["customer"],
    "status": "active",
    "token": "9|67jJJFBrThhHx5WlEbnXC6DLdPNJqT2sK9ha6TLMeb1696ef",
    "created_at": "2025-09-13T12:30:18.000000Z",
    "updated_at": "2025-09-13T12:30:18.000000Z"
  }
}
```

#### POST /auth/register
**Description:** User registration with phone and password
**Request Body:**
```json
{
  "phone": "+255712345678",
  "password": "password123"
}
```

#### POST /auth/logout
**Description:** User logout
**Headers:** Authorization required

#### GET /users/me
**Description:** Get current user profile
**Headers:** Authorization required
**Response:**
```json
{
  "success": true,
  "message": "User profile retrieved successfully",
  "data": {
    "id": 10,
    "phone": "+255712345678",
    "roles": ["customer"],
    "status": "active",
    "nida_number": null,
    "full_name": null,
    "email": null,
    "location": null,
    "bio": null,
    "skills": null,
    "languages": null,
    "veta_certificate": null,
    "portfolio_images": null,
    "created_at": "2025-09-13T12:30:18.000000Z",
    "updated_at": "2025-09-13T12:30:18.000000Z",
    "fundi_profile": null
  }
}
```

### Job Endpoints

#### GET /jobs
**Description:** Get list of jobs with pagination and filters
**Query Parameters:**
- `page` (int): Page number (default: 1)
- `limit` (int): Items per page (default: 20)
- `category` (string): Filter by category
- `location` (string): Filter by location
- `search` (string): Search term

**Response:**
```json
{
  "success": true,
  "message": "Jobs retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [],
    "first_page_url": "http://88.223.92.135:8002/api/jobs?page=1",
    "from": null,
    "last_page": 1,
    "last_page_url": "http://88.223.92.135:8002/api/jobs?page=1",
    "links": [
      {
        "url": null,
        "label": "« Previous",
        "page": null,
        "active": false
      },
      {
        "url": "http://88.223.92.135:8002/api/jobs?page=1",
        "label": "1",
        "page": 1,
        "active": true
      },
      {
        "url": null,
        "label": "Next »",
        "page": null,
        "active": false
      }
    ],
    "next_page_url": null,
    "path": "http://88.223.92.135:8002/api/jobs",
    "per_page": 15,
    "prev_page_url": null,
    "to": null,
    "total": 0
  }
}
```

#### POST /jobs
**Description:** Create a new job posting
**Headers:** Authorization required
**Request Body:**
```json
{
  "title": "Fix Leaky Faucet",
  "description": "Need to fix a leaky faucet in the kitchen",
  "location": "Dar es Salaam",
  "budget": 25000,
  "category_id": 1,
  "urgency": "medium",
  "deadline": "2025-12-31",
  "location_lat": -6.7924,
  "location_lng": 39.2083,
  "required_skills": ["plumbing", "repair"],
  "image_urls": ["https://example.com/image1.jpg"]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Job created successfully",
  "data": {
    "customer_id": 11,
    "category_id": 1,
    "title": "Fix Leaky Faucet",
    "description": "Need to fix a leaky faucet in the kitchen",
    "budget": "25000.00",
    "deadline": "2025-12-31T00:00:00.000000Z",
    "location_lat": null,
    "location_lng": null,
    "updated_at": "2025-09-13T18:11:32.000000Z",
    "created_at": "2025-09-13T18:11:32.000000Z",
    "id": 1,
    "customer": {
      "id": 11,
      "phone": "+255712345679",
      "roles": ["customer"],
      "status": "active",
      "nida_number": null,
      "full_name": null,
      "email": null,
      "location": null,
      "bio": null,
      "skills": null,
      "languages": null,
      "veta_certificate": null,
      "portfolio_images": null,
      "created_at": "2025-09-13T12:31:00.000000Z",
      "updated_at": "2025-09-13T12:31:00.000000Z"
    },
    "category": {
      "id": 1,
      "name": "Plumbing",
      "description": "Plumbing services and repairs",
      "created_at": "2025-09-13T12:07:39.000000Z",
      "updated_at": "2025-09-13T12:07:39.000000Z"
    }
  }
}
```

#### GET /jobs/{id}
**Description:** Get specific job by ID
**Headers:** Authorization required

### Category Endpoints

#### GET /categories
**Description:** Get list of job categories
**Response:**
```json
{
  "success": true,
  "message": "Categories retrieved successfully",
  "data": [
    {
      "id": 3,
      "name": "Carpentry",
      "description": "Woodwork and furniture making",
      "created_at": "2025-09-13T12:07:39.000000Z",
      "updated_at": "2025-09-13T12:07:39.000000Z"
    }
  ]
}
```

### Dashboard Endpoints

#### GET /dashboard/stats
**Description:** Get dashboard statistics
**Headers:** Authorization required

#### GET /dashboard/activity
**Description:** Get recent activity
**Headers:** Authorization required

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "phone": ["The phone field is required."],
    "password": ["The password must be at least 6 characters."]
  }
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Unauthenticated"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "Access denied"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Internal server error"
}
```

## Rate Limiting
- 60 requests per minute per IP
- 1000 requests per hour per authenticated user

## Response Format
All API responses follow this format:
```json
{
  "success": boolean,
  "message": string,
  "data": object | array | null
}
```

## Pagination
Paginated responses include:
- `current_page`: Current page number
- `last_page`: Total number of pages
- `per_page`: Items per page
- `total`: Total number of items
- `from`: Starting item number
- `to`: Ending item number
- `next_page_url`: URL for next page (null if last page)
- `prev_page_url`: URL for previous page (null if first page)

## Status Codes
- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `422`: Validation Error
- `500`: Internal Server Error

## SDK Usage

### JobService
```dart
// Get jobs
final result = await JobService().getJobs(
  page: 1,
  limit: 20,
  category: 'plumbing',
  location: 'Dar es Salaam',
);

// Create job
final result = await JobService().createJob(
  title: 'Fix pipe',
  description: 'Fix leaking pipe',
  category: 'plumbing',
  location: 'Dar es Salaam',
  budget: 50000,
  budgetType: 'fixed',
  deadline: DateTime.now().add(Duration(days: 7)),
  requiredSkills: ['plumbing', 'repair'],
);
```

### AuthService
```dart
// Login
final result = await AuthService().login(
  phoneNumber: '+255712345678',
  password: 'password123',
);

// Register
final result = await AuthService().register(
  phoneNumber: '+255712345678',
  password: 'password123',
);
```

### ProfileService
```dart
// Get profile
final profile = await ProfileService().getProfile('');

// Update profile
final result = await ProfileService().updateProfile(
  userId: '10',
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
);
```

## Testing
Use the provided test endpoints for development:
- Test login: `+255712345678` / `password123`
- Test categories: Available via `/categories` endpoint
- Test jobs: Empty by default, create via `/jobs` endpoint

## Support
For API support or questions, contact the development team.
