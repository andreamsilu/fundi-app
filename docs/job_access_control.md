# Job Access Control System

## 📋 **Overview**

The job access control system ensures proper separation between:
- **Available Jobs** - Public feed that everyone can view
- **My Jobs** - Only job owners can manage their own jobs
- **Job Applications** - Fundis can apply to available jobs, customers can manage applications for their own jobs

## 🔧 **API Endpoints**

### **Available Jobs (Public Feed)**
- **Endpoint**: `GET /api/jobs`
- **Purpose**: Show all available jobs for everyone to view
- **Access**: All authenticated users (customers, fundis, admins)
- **Data**: All jobs with status 'open' or 'in_progress'
- **Use Case**: Home page, job browsing, fundi job search

### **My Jobs (User's Own Jobs)**
- **Endpoint**: `GET /api/jobs/my-jobs`
- **Purpose**: Show only jobs owned by the current user
- **Access**: Only job owners can access their own jobs
- **Data**: Jobs where `customer_id = current_user.id`
- **Use Case**: Job management, viewing applications, updating job status

### **Job Applications**
- **Endpoint**: `POST /api/jobs/{jobId}/apply`
- **Purpose**: Fundis apply to available jobs
- **Access**: Only fundis can apply to jobs
- **Data**: Creates job application record

- **Endpoint**: `GET /api/jobs/{jobId}/applications`
- **Purpose**: View applications for a specific job
- **Access**: Only job owners can view applications for their jobs
- **Data**: Applications for the specified job

- **Endpoint**: `GET /api/job-applications/my-applications`
- **Purpose**: View fundi's own applications
- **Access**: Only fundis can view their own applications
- **Data**: Applications where `fundi_id = current_user.id`

## 🏗️ **Implementation Details**

### **API Controller Methods**

#### **JobController::index()**
```php
// Available jobs (public feed)
public function index(Request $request): JsonResponse
{
    // Show all available jobs (public feed)
    // No user-specific filtering here
    $query = Job::with(['customer:id,full_name,phone,email', 'category:id,name', 'applications', 'media']);
    // ... filtering and pagination
}
```

#### **JobController::myJobs()**
```php
// User's own jobs
public function myJobs(Request $request): JsonResponse
{
    // Only show jobs owned by the current user
    $query = Job::with(['customer:id,full_name,phone,email', 'category:id,name', 'applications', 'media']);
    $query->where('customer_id', $user->id);
    // ... filtering and pagination
}
```

### **Flutter App Implementation**

#### **JobService Methods**
```dart
// Available jobs (public feed)
Future<JobListResult> getAvailableJobs({...}) async {
  final response = await _apiClient.get<Map<String, dynamic>>(
    ApiEndpoints.jobs, // /jobs
    queryParameters: queryParams,
    ...
  );
}

// User's own jobs
Future<JobListResult> getMyJobs({...}) async {
  final response = await _apiClient.get<Map<String, dynamic>>(
    ApiEndpoints.myJobs, // /jobs/my-jobs
    queryParameters: queryParams,
    ...
  );
}
```

#### **JobListScreen Logic**
```dart
// Smart endpoint selection based on screen title
final result = widget.title == 'My Jobs' || widget.title == 'Applied Jobs'
    ? await JobService().getMyJobs(...)      // User's own jobs
    : await JobService().getAvailableJobs(...); // Public job feed
```

## 📱 **Screen Configuration**

### **Customer Dashboard**
```dart
// Customer screens
return [
  JobListScreen(title: 'Available Jobs'), // Public feed
  FundiFeedScreen(), // Find Fundis
  JobListScreen(title: 'My Jobs'), // Own jobs
  ProfileScreen(),
];
```

### **Fundi Dashboard**
```dart
// Fundi screens
return [
  JobListScreen(title: 'Find Jobs'), // Available jobs
  JobListScreen(title: 'Applied Jobs'), // Own applications
  ProfileScreen(),
];
```

## 🔐 **Permission System**

### **Job Viewing Permissions**
- **Available Jobs**: All authenticated users can view
- **My Jobs**: Only job owners can view their own jobs
- **Job Details**: All authenticated users can view job details

### **Job Management Permissions**
- **Create Jobs**: Only customers can create jobs
- **Update Jobs**: Only job owners can update their jobs
- **Delete Jobs**: Only job owners can delete their jobs
- **View Applications**: Only job owners can view applications for their jobs

### **Application Permissions**
- **Apply to Jobs**: Only fundis can apply to available jobs
- **View My Applications**: Only fundis can view their own applications
- **Manage Applications**: Only job owners can manage applications for their jobs

## 🎯 **User Roles & Access**

### **Customer Role**
- ✅ **View Available Jobs** - Browse all open jobs
- ✅ **Create Jobs** - Post new job requests
- ✅ **Manage My Jobs** - Update, delete own jobs
- ✅ **View Applications** - See who applied to their jobs
- ✅ **Manage Applications** - Accept/reject applications

### **Fundi Role**
- ✅ **View Available Jobs** - Browse all open jobs
- ✅ **Apply to Jobs** - Submit applications to jobs
- ✅ **View My Applications** - See own application status
- ❌ **Create Jobs** - Cannot create jobs
- ❌ **Manage Other Jobs** - Cannot manage other people's jobs

### **Admin Role**
- ✅ **View All Jobs** - See all jobs in system
- ✅ **Manage All Jobs** - Update/delete any job
- ✅ **View All Applications** - See all applications
- ✅ **Manage All Applications** - Accept/reject any application

## 📊 **Data Flow**

### **Available Jobs Flow**
1. User opens "Available Jobs" screen
2. App calls `GET /api/jobs`
3. API returns all available jobs
4. App displays jobs in list
5. User can view job details and apply (if fundi)

### **My Jobs Flow**
1. User opens "My Jobs" screen
2. App calls `GET /api/jobs/my-jobs`
3. API returns only user's own jobs
4. App displays jobs in list
5. User can manage their jobs and view applications

### **Application Flow**
1. Fundi views available job
2. Fundi clicks "Apply" button
3. App calls `POST /api/jobs/{jobId}/apply`
4. API creates application record
5. Customer can view application in "My Jobs"

## 🧪 **Testing**

### **API Endpoint Tests**
```bash
# Test available jobs
curl -X GET "http://185.213.27.206:8081/api/jobs" \
  -H "Authorization: Bearer $TOKEN"

# Test my jobs
curl -X GET "http://185.213.27.206:8081/api/jobs/my-jobs" \
  -H "Authorization: Bearer $TOKEN"
```

### **Expected Results**
- **Available Jobs**: Returns all open jobs (1 job in test)
- **My Jobs**: Returns only user's own jobs (1 job in test)
- **Proper Separation**: Different data sets for different endpoints

## 🚀 **Benefits**

### **Security**
- **Data Isolation**: Users can only access their own data
- **Role-Based Access**: Different permissions for different roles
- **API Security**: Proper authentication and authorization

### **User Experience**
- **Clear Separation**: Different screens for different purposes
- **Intuitive Navigation**: Easy to understand job management
- **Efficient Workflow**: Streamlined job application process

### **Scalability**
- **Modular Design**: Easy to add new features
- **Flexible Permissions**: Easy to modify access controls
- **Performance**: Optimized queries for different use cases

## 📝 **Usage Examples**

### **Customer Workflow**
1. Browse available jobs on home page
2. Create new job posting
3. Manage own jobs in "My Jobs" section
4. View and manage applications for own jobs

### **Fundi Workflow**
1. Browse available jobs on home page
2. Apply to interesting jobs
3. View own applications in "Applied Jobs" section
4. Track application status

### **Admin Workflow**
1. View all jobs in system
2. Manage any job or application
3. Monitor system activity
4. Handle disputes or issues

This comprehensive job access control system ensures proper data separation and user experience while maintaining security and scalability.
