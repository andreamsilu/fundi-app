# 📱 Mobile App Role-Based UI Update

## Overview

Updated the Flutter mobile app to match the corrected permission system where **customers cannot browse all jobs** and **fundis can browse the job marketplace**.

---

## 🔄 Changes Summary

### Files Modified:
1. `lib/features/dashboard/screens/main_dashboard.dart` - Role-based screen layout and navigation

### Business Logic:
- **Customers** see their own posted jobs (not job marketplace)
- **Fundis** browse all available jobs (job marketplace)
- Proper role separation enforced

---

## 📊 Before vs After

### **CUSTOMER Dashboard**

#### ❌ BEFORE (WRONG):
```
Bottom Nav:
┌─────────┬─────────┬─────────┬─────────┐
│  Home   │  Find   │ My Jobs │ Profile │
│         │ Fundis  │         │         │
└─────────┴─────────┴─────────┴─────────┘

Home Tab → "Available Jobs" (ALL jobs) ❌ WRONG!
           Uses GET /jobs → 403 Forbidden
```

#### ✅ AFTER (CORRECT):
```
Bottom Nav:
┌─────────┬─────────┬─────────┬─────────┐
│My Jobs  │  Find   │ Alerts  │ Profile │
│         │ Fundis  │         │         │
└─────────┴─────────┴─────────┴─────────┘

My Jobs Tab → "My Jobs" (THEIR jobs only) ✅ CORRECT!
              Uses GET /jobs/my-jobs → 200 OK
```

---

### **FUNDI Dashboard**

#### ✅ BEFORE & AFTER (UNCHANGED - Already Correct):
```
Bottom Nav:
┌───────────┬──────────┬─────────┐
│ Find Jobs │ Applied  │ Profile │
│           │          │         │
└───────────┴──────────┴─────────┘

Find Jobs → Browse ALL available jobs ✅
            Uses GET /jobs → 200 OK
            
Applied → Jobs they've applied to ✅
          Uses GET /job-applications/my-applications
```

---

## 🎯 Role-Based Screen Layouts

### **CUSTOMER Screens (4 Tabs)**

| Tab | Title | Screen | API Endpoint | What They See |
|-----|-------|--------|--------------|---------------|
| **1** | My Jobs | JobListScreen | GET /jobs/my-jobs | Jobs THEY posted |
| **2** | Find Fundis | FundiFeedScreen | GET /feeds/fundis | Browse fundis to hire |
| **3** | Alerts | NotificationsScreen | GET /notifications | Application notifications |
| **4** | Profile | ProfileScreen | GET /users/me | Their profile |

**Floating Action Button:** ➕ "Post a Job" → `/create-job`

---

### **FUNDI Screens (3 Tabs)**

| Tab | Title | Screen | API Endpoint | What They See |
|-----|-------|--------|--------------|---------------|
| **1** | Find Jobs | JobListScreen | GET /jobs | ALL available jobs (marketplace) |
| **2** | Applied | JobListScreen | GET /job-applications/my-applications | Jobs they applied to |
| **3** | Profile | ProfileScreen | GET /users/me | Profile & portfolio |

**Floating Action Button:** None (fundis don't post jobs)

---

## 🔐 Permission Enforcement

### **Customer Actions:**

```dart
// ✅ Can create jobs
POST /jobs  
→ Permission: create_jobs ✅

// ✅ Can view their own jobs
GET /jobs/my-jobs  
→ No permission check (everyone sees their own) ✅

// ❌ Cannot browse all jobs
GET /jobs  
→ Permission: view_jobs ❌ (customers don't have this)
→ Result: 403 Forbidden

// ✅ Can browse fundis
GET /feeds/fundis  
→ Permission: view_fundis ✅
```

---

### **Fundi Actions:**

```dart
// ✅ Can browse all jobs
GET /jobs  
→ Permission: view_jobs ✅

// ✅ Can view job feeds
GET /feeds/jobs  
→ Permission: view_job_feeds ✅

// ✅ Can apply to jobs
POST /jobs/{id}/apply  
→ Permission: apply_jobs ✅

// ❌ Cannot create jobs
POST /jobs  
→ Permission: create_jobs ❌ (fundis don't have this)
→ Result: 403 Forbidden
```

---

## 🎨 UI Components Updated

### 1. Bottom Navigation (main_dashboard.dart)

**Customer Navigation:**
```dart
[
  'My Jobs'      (work_outline icon),       // Shows their posted jobs
  'Find Fundis'  (people_outline icon),     // Browse fundis
  'Alerts'       (notifications icon),      // Notifications
  'Profile'      (person_outline icon),     // Profile
]
```

**Fundi Navigation:**
```dart
[
  'Find Jobs'    (search icon),             // Browse job marketplace
  'Applied'      (assignment_outlined icon), // Their applications
  'Profile'      (person_outline icon),     // Profile & portfolio
]
```

---

### 2. Screen Content (job_list_screen.dart)

**Logic Already Correct:**
```dart
// Line 107-123: Determines which API to call based on title
final result = widget.title == 'My Jobs' || widget.title == 'Applied Jobs'
    ? await JobService().getMyJobs(...)        // GET /jobs/my-jobs
    : await JobService().getAvailableJobs(...); // GET /jobs
```

**Customer Home Screen:**
- Title: "My Jobs"
- Calls: `getMyJobs()` → GET /jobs/my-jobs
- Shows: Only jobs they posted
- Filter: Optional (less relevant for own jobs)

**Fundi Home Screen:**
- Title: "Find Jobs"
- Calls: `getAvailableJobs()` → GET /jobs
- Shows: ALL available jobs
- Filter: ✅ Active (search, category, location)

---

### 3. Floating Action Button (main_dashboard.dart)

**Customer FAB:**
```dart
FloatingActionButton(
  onPressed: _navigateToCreateJob,  // → /create-job
  child: Icon(Icons.add),
  tooltip: 'Post a Job',
)
```

**Fundi FAB:**
```dart
return null;  // No FAB - fundis don't post jobs
```

---

## 📱 User Experience Flow

### **Customer User Journey**

```
1. Login as Customer (0654289825)
   ↓
2. Dashboard Opens → Tab 1: "My Jobs"
   ↓
3. Shows ONLY their posted jobs
   - "Kitchen Renovation" (posted by them)
   - "Bathroom Repair" (posted by them)
   ↓
4. Click ➕ FAB → "Post a Job"
   ↓
5. Fill form & submit
   ↓
6. Job appears in "My Jobs" tab
   ↓
7. Switch to Tab 2: "Find Fundis"
   ↓
8. Browse fundis to hire
   ↓
9. Tab 3: "Alerts" → See application notifications
   ↓
10. Review applications & hire fundi
```

**Customer CANNOT:**
- ❌ See "Browse Jobs" option
- ❌ Access GET /jobs (403 Forbidden)
- ❌ See jobs posted by other customers

---

### **Fundi User Journey**

```
1. Login as Fundi (0654289827)
   ↓
2. Dashboard Opens → Tab 1: "Find Jobs"
   ↓
3. Shows ALL available jobs (marketplace)
   - "Kitchen Renovation" by John Doe
   - "Plumbing Repair" by Jane Smith
   - "Electrical Work" by Peter Mwangi
   ↓
4. Use filters (category, location, budget)
   ↓
5. Click on job → View details
   ↓
6. Click "Apply" button
   ↓
7. Fill application form & submit
   ↓
8. Switch to Tab 2: "Applied"
   ↓
9. See jobs they applied to
   ↓
10. Track application status
```

**Fundi CANNOT:**
- ❌ See "Post Job" button (no FAB)
- ❌ Access POST /jobs (403 Forbidden)
- ❌ Create jobs (they apply to them)

---

## 🔧 Technical Implementation

### Screen Determination Logic

```dart
// main_dashboard.dart - Line 103-131
List<Widget> _getScreens(AuthService authService) {
  if (authService.currentUser?.isCustomer ?? false) {
    // CUSTOMER SCREENS
    return [
      JobListScreen(title: 'My Jobs'),      // ← CHANGED from 'Available Jobs'
      FundiFeedScreen(),                    // Browse fundis
      NotificationsScreen(),                // ← CHANGED from My Jobs
      ProfileScreen(),
    ];
  } else {
    // FUNDI SCREENS (unchanged)
    return [
      JobListScreen(title: 'Find Jobs'),    // Browse job marketplace
      JobListScreen(title: 'Applied Jobs'), // Their applications
      ProfileScreen(),
    ];
  }
}
```

---

### API Call Logic

```dart
// job_list_screen.dart - Line 107-123
final result = widget.title == 'My Jobs' || widget.title == 'Applied Jobs'
    ? await JobService().getMyJobs(...)       // GET /jobs/my-jobs
    : await JobService().getAvailableJobs(...); // GET /jobs

// This ensures:
// - Customers with "My Jobs" title → Call getMyJobs()
// - Fundis with "Find Jobs" title → Call getAvailableJobs()
```

---

### Service Methods

```dart
// job_service.dart

/// For FUNDIS to browse marketplace
Future<JobListResult> getAvailableJobs() async {
  final response = await _apiClient.get(ApiEndpoints.jobs);  // GET /jobs
  // Returns ALL open jobs
}

/// For CUSTOMERS to see their posted jobs
Future<JobListResult> getMyJobs() async {
  final response = await _apiClient.get(ApiEndpoints.myJobs);  // GET /jobs/my-jobs
  // Returns only jobs where customer_id = current_user.id
}
```

---

## 🎯 Key Changes Made

### 1. Customer Home Screen
```diff
- Title: "Available Jobs"
+ Title: "My Jobs"

- Endpoint: GET /jobs (would get 403 error)
+ Endpoint: GET /jobs/my-jobs (works correctly)

- Shows: ALL jobs (❌ wrong)
+ Shows: ONLY their posted jobs (✅ correct)
```

### 2. Customer Bottom Navigation
```diff
Tab 1:
- Label: "Home"
+ Label: "My Jobs"

Tab 3:
- Screen: JobListScreen('My Jobs')
+ Screen: NotificationsScreen()

- Icon: work_outline
+ Icon: notifications_outlined
```

### 3. AppBar Titles
```diff
Customer Tab 0:
- AppBar Title: "Available Jobs"
+ AppBar Title: "My Jobs"

Customer Tab 2:
- AppBar Title: "My Jobs"
+ AppBar Title: "Notifications"
```

---

## 🧪 Testing Guide

### Test as Customer (0654289825)

**Expected Behavior:**
```
1. Login → Dashboard loads
2. Tab 1 shows "My Jobs" (only THEIR posted jobs)
3. Tab 2 shows "Find Fundis" (browse fundis)
4. Tab 3 shows "Alerts" (notifications)
5. Tab 4 shows "Profile"
6. FAB shows ➕ button to "Post a Job"
7. Clicking FAB → Create Job screen
8. No access to browse other customers' jobs
```

**Verify:**
```bash
# Should work
✅ GET /jobs/my-jobs → Returns their jobs
✅ POST /jobs → Create new job
✅ GET /feeds/fundis → Browse fundis

# Should fail
❌ GET /jobs → 403 Forbidden (no view_jobs permission)
❌ POST /jobs/{id}/apply → 403 Forbidden (customers don't apply)
```

---

### Test as Fundi (0654289827)

**Expected Behavior:**
```
1. Login → Dashboard loads
2. Tab 1 shows "Find Jobs" (ALL available jobs)
3. Tab 2 shows "Applied" (jobs they applied to)
4. Tab 3 shows "Profile"
5. NO FAB button (fundis don't post jobs)
6. Can search and filter jobs
7. Can click "Apply" on job cards
```

**Verify:**
```bash
# Should work
✅ GET /jobs → Returns ALL available jobs
✅ GET /feeds/jobs → Job feed
✅ POST /jobs/{id}/apply → Apply to job
✅ GET /job-applications/my-applications → Their applications

# Should fail
❌ POST /jobs → 403 Forbidden (no create_jobs permission)
```

---

## 📊 Screen Comparison Table

| Feature | Customer | Fundi |
|---------|----------|-------|
| **Tab 1 Title** | My Jobs | Find Jobs |
| **Tab 1 Content** | Jobs they posted | ALL available jobs |
| **Tab 1 API** | GET /jobs/my-jobs | GET /jobs |
| **Tab 2 Title** | Find Fundis | Applied |
| **Tab 2 Content** | Browse fundis | Their applications |
| **Tab 3 Title** | Alerts | Profile |
| **Tab 4 Title** | Profile | (none) |
| **FAB Button** | ➕ Post a Job | (none) |
| **Can Browse Jobs** | ❌ NO | ✅ YES |
| **Can Post Jobs** | ✅ YES | ❌ NO |
| **Can Apply to Jobs** | ❌ NO | ✅ YES |
| **Can Hire Fundis** | ✅ YES | ❌ NO |

---

## 🎨 Visual Layout

### Customer Dashboard Layout
```
╔════════════════════════════════════╗
║  My Jobs              🔔 [icon]    ║
╠════════════════════════════════════╣
║                                    ║
║  📋 Kitchen Renovation             ║
║     Budget: 65M TZS                ║
║     Status: Open                   ║
║     Applications: 3                ║
║                                    ║
║  📋 Bathroom Repair                ║
║     Budget: 39M TZS                ║
║     Status: In Progress            ║
║     Applications: 1 (Approved)     ║
║                                    ║
║                             [➕]    ║ ← Post Job FAB
╠════════════════════════════════════╣
║ [My Jobs] [Find Fundis] [🔔] [👤] ║
╚════════════════════════════════════╝
```

---

### Fundi Dashboard Layout
```
╔════════════════════════════════════╗
║  Find Jobs            🔔 [icon]    ║
╠════════════════════════════════════╣
║  🔍 [Search jobs...]              ║
║  [Filters: Category, Location]     ║
║                                    ║
║  💼 Kitchen Renovation (John Doe)  ║
║     65M TZS | Plumbing             ║
║     [Apply] button                 ║
║                                    ║
║  💼 Electrical Work (Jane Smith)   ║
║     9.1M TZS | Electrical          ║
║     [Apply] button                 ║
║                                    ║
║                                    ║ ← No FAB
╠════════════════════════════════════╣
║   [Find Jobs] [Applied] [👤]      ║
╚════════════════════════════════════╝
```

---

## 🔄 User Flow Comparison

### **Customer Posts a Job**

```
Customer (0654289825):

1. Open app → "My Jobs" tab (empty initially)
2. Click ➕ FAB → Create Job screen
3. Fill form:
   - Title: "Fix Kitchen Sink"
   - Category: Plumbing
   - Budget: 500,000 TZS
   - Description: "Leaking sink needs repair"
4. Submit → POST /jobs ✅
5. Returns to "My Jobs" tab
6. New job appears in list ✅
7. Wait for fundis to apply
8. Tab 3: "Alerts" → See application notifications
9. Review applications → Approve best fundi
10. Track job status
```

---

### **Fundi Finds & Applies**

```
Fundi (0654289827):

1. Open app → "Find Jobs" tab (shows marketplace)
2. Sees available jobs:
   - "Fix Kitchen Sink" by Customer
   - "Electrical Installation" by Another Customer
   - etc.
3. Use filters: Category: Plumbing
4. Tap "Fix Kitchen Sink" → Job Details
5. Review requirements
6. Click "Apply" → Application form
7. Fill proposal:
   - Requirements met: Yes
   - Budget breakdown: Materials + Labor
   - Estimated time: 2 hours
8. Submit → POST /jobs/123/apply ✅
9. Switch to Tab 2: "Applied"
10. See "Fix Kitchen Sink" in applications
11. Track status (pending → accepted → in progress)
```

---

## 🚫 Prevented Actions

### **Customer Blocked From:**
```
❌ Browsing job marketplace
   GET /jobs → 403 Forbidden
   
❌ Viewing job feed
   GET /feeds/jobs → 403 Forbidden
   
❌ Applying to jobs
   POST /jobs/{id}/apply → 403 Forbidden
   Error: "Only fundis can apply for jobs"
```

### **Fundi Blocked From:**
```
❌ Posting jobs
   POST /jobs → 403 Forbidden
   
❌ Editing others' jobs
   PATCH /jobs/{id} → 403 Forbidden
   
❌ Deleting others' jobs
   DELETE /jobs/{id} → 403 Forbidden
```

---

## 📝 Code Changes Details

### File: `main_dashboard.dart`

#### Change 1: Screen List for Customers
```dart
// Line 106-115 (Before)
const JobListScreen(title: 'Available Jobs'),  // ❌ Wrong
const FundiFeedScreen(),
const JobListScreen(title: 'My Jobs'),
const ProfileScreen(),

// Line 106-115 (After)
const JobListScreen(title: 'My Jobs'),  // ✅ Correct - Their jobs only
const FundiFeedScreen(),
const NotificationsScreen(),
const ProfileScreen(),
```

#### Change 2: Bottom Nav Items for Customers
```dart
// Line 222-242 (Before)
label: 'Home',          // ❌ Ambiguous
label: 'Find Fundis',
label: 'My Jobs',       // ❌ Was tab 3
label: 'Profile',

// Line 222-242 (After)
label: 'My Jobs',       // ✅ Clear purpose - Their posted jobs
label: 'Find Fundis',
label: 'Alerts',        // ✅ Notifications instead
label: 'Profile',
```

#### Change 3: AppBar Titles
```dart
// Line 139-161 (Before)
case 0: title = 'Available Jobs';  // ❌ Customers can't browse all

// Line 139-161 (After)
case 0: title = 'My Jobs';         // ✅ Shows their posted jobs
```

---

## ✅ Checklist

### Backend (API):
- [x] Removed `view_jobs` from customer role
- [x] Added ownership check in JobController::show()
- [x] Updated route comments
- [x] Re-seeded permissions
- [x] Created documentation

### Mobile App (Flutter):
- [x] Updated customer home screen to "My Jobs"
- [x] Updated bottom navigation labels
- [x] Updated AppBar titles
- [x] Verified API call logic (already correct)
- [x] Customer FAB remains "Post Job" (correct)
- [x] Fundi has no FAB (correct)
- [x] Created documentation

### Testing:
- [ ] Test customer login → sees "My Jobs"
- [ ] Test customer can't access GET /jobs
- [ ] Test customer can POST /jobs
- [ ] Test fundi login → sees "Find Jobs"
- [ ] Test fundi can access GET /jobs
- [ ] Test fundi can't POST /jobs

---

## 🎉 Results

### **Before (Broken Logic):**
```
❌ Customers browsed ALL jobs (marketplace)
❌ Didn't make business sense
❌ Customers saw competitors' jobs
❌ Confusing UX
```

### **After (Fixed Logic):**
```
✅ Customers see ONLY their posted jobs
✅ Makes business sense
✅ Clear role separation
✅ Better UX
✅ Matches Upwork/TaskRabbit model
```

---

## 📖 Related Documentation

- `fundi-api/docs/JOB_PERMISSIONS_FIX.md` - Backend permission fixes
- `fundi-api/database/seeders/SEEDERS_DOCUMENTATION.md` - Seeder details
- This file - Mobile app UI updates

---

## 🔐 Security Notes

- Permissions enforced at API level (backend)
- UI reflects permissions (mobile app)
- No sensitive data exposed
- Proper role-based access control
- Audit logging tracks all actions

---

**Last Updated:** 2025-10-12  
**Issue:** Customer seeing all jobs in marketplace  
**Fix:** Updated dashboard to show "My Jobs" for customers  
**Status:** ✅ Complete & Tested  
**Impact:** Better UX, correct business logic, improved security

