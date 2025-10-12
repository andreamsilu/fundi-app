# 🎯 Customer vs Fundi - Quick Reference Guide

## At a Glance

| | 👔 CUSTOMER | 🔧 FUNDI |
|---|---|---|
| **Main Purpose** | POST jobs, HIRE fundis | BROWSE jobs, GET hired |
| **Home Screen** | My Posted Jobs | Job Marketplace |
| **Can Browse Jobs?** | ❌ NO | ✅ YES |
| **Can Post Jobs?** | ✅ YES | ❌ NO |
| **Can Apply to Jobs?** | ❌ NO | ✅ YES |
| **Primary Action** | ➕ Post Job | 🔍 Find & Apply |

---

## 📱 Mobile App Screens

### **CUSTOMER (4 Tabs)**
```
┌─────────┬───────────┬─────────┬─────────┐
│My Jobs  │Find Fundis│ Alerts  │ Profile │
└─────────┴───────────┴─────────┴─────────┘

Tab 1: My Jobs        → Jobs I posted
Tab 2: Find Fundis    → Browse fundis to hire  
Tab 3: Alerts         → Application notifications
Tab 4: Profile        → My account

[➕] FAB: Post a Job
```

### **FUNDI (3 Tabs)**
```
┌───────────┬──────────┬─────────┐
│ Find Jobs │ Applied  │ Profile │
└───────────┴──────────┴─────────┘

Tab 1: Find Jobs → Browse job marketplace
Tab 2: Applied   → Jobs I applied to
Tab 3: Profile   → My profile & portfolio

No FAB (fundis don't post)
```

---

## 🔐 Permissions Matrix

| Permission | Customer | Fundi | Admin |
|-----------|----------|-------|-------|
| **view_jobs** | ❌ | ✅ | ✅ |
| **create_jobs** | ✅ | ❌ | ✅ |
| **edit_jobs** | ✅ (own) | ❌ | ✅ |
| **delete_jobs** | ✅ (own) | ❌ | ✅ |
| **apply_jobs** | ❌ | ✅ | ✅ |
| **view_fundis** | ✅ | ✅ | ✅ |
| **create_portfolio** | ❌ | ✅ | ✅ |
| **view_portfolio** | ✅ | ✅ | ✅ |
| **manage_job_applications** | ✅ (own) | ❌ | ✅ |
| **approve_job_applications** | ✅ (own) | ❌ | ✅ |

---

## 🌐 API Endpoints Access

### **Customer Can Access:**
```
✅ GET  /jobs/my-jobs           (view their posted jobs)
✅ POST /jobs                   (create new job)
✅ PATCH /jobs/{id}             (edit their job)
✅ DELETE /jobs/{id}            (delete their job)
✅ GET /jobs/{id}               (if they own it)
✅ GET /feeds/fundis            (browse fundis)
✅ GET /jobs/{id}/applications  (view applications to their job)
✅ PATCH /job-applications/{id}/status (approve/reject)

❌ GET /jobs                    (can't browse all jobs)
❌ GET /feeds/jobs              (can't access job feed)
❌ POST /jobs/{id}/apply        (can't apply to jobs)
```

### **Fundi Can Access:**
```
✅ GET /jobs                    (browse all available jobs)
✅ GET /feeds/jobs              (job feed with filters)
✅ GET /feeds/jobs/{id}         (job details)
✅ GET /jobs/{id}               (view any job details)
✅ POST /jobs/{id}/apply        (apply to job)
✅ GET /job-applications/my-applications (their applications)
✅ GET /feeds/fundis            (browse other fundis)
✅ POST /portfolio              (create portfolio item)

❌ POST /jobs                   (can't create jobs)
❌ PATCH /jobs/{id}             (can't edit jobs)
❌ DELETE /jobs/{id}            (can't delete jobs)
```

---

## 💡 Real-World Analogy

### Like Uber:
- **Customer** = Passenger (requests ride, doesn't browse ride requests)
- **Fundi** = Driver (browses ride requests, accepts them)

### Like Upwork:
- **Customer** = Client (posts projects, hires freelancers)
- **Fundi** = Freelancer (browses projects, applies)

### Like TaskRabbit:
- **Customer** = Task Poster (needs help)
- **Fundi** = Tasker (provides help)

---

## 🔄 Typical User Flows

### **Customer Flow:**
```
1. Need plumbing help
2. Open app → "My Jobs" (shows previous jobs)
3. Click ➕ → "Post a Job"
4. Fill details & submit
5. Wait for fundi applications
6. Check "Alerts" → See 3 fundis applied
7. Go to "Find Fundis" → View fundi profiles
8. Review applications & portfolios
9. Approve best fundi
10. Track job progress
11. Approve completed work
12. Rate fundi
```

### **Fundi Flow:**
```
1. Looking for work
2. Open app → "Find Jobs" (marketplace)
3. Browse available jobs
4. Filter by category: Plumbing
5. See "Fix Kitchen Sink" - 500K TZS
6. Tap job → View details
7. Click "Apply"
8. Fill application form
9. Submit application
10. Go to "Applied" → Track status
11. Get approved → Start work
12. Submit completed work
13. Get paid
```

---

## 📊 Dashboard Analytics

### **Customer Dashboard Shows:**
- Total jobs posted
- Active jobs (open, in progress)
- Completed jobs
- Total spent
- Applications received
- Average hire time

### **Fundi Dashboard Shows:**
- Jobs applied to
- Applications pending/approved/rejected
- Jobs completed
- Total earned
- Average rating
- Portfolio views

---

## 🎨 UI Elements

### **Customer UI:**
```dart
// Home Screen
- Job cards (their posted jobs)
- "No jobs yet? Post your first job!" (empty state)
- FAB: ➕ Post a Job

// Job Card Actions
- View applications
- Edit job
- Delete job
- Mark as completed

// Navigation
- My Jobs (posted jobs)
- Find Fundis (browse)
- Alerts (notifications)
- Profile
```

### **Fundi UI:**
```dart
// Home Screen
- Job cards (ALL available jobs)
- Search & filter bar
- "No jobs match your criteria" (empty state)
- NO FAB

// Job Card Actions
- View details
- Apply to job
- Save for later

// Navigation
- Find Jobs (marketplace)
- Applied (applications)
- Profile (portfolio)
```

---

## 💰 Payment Differences

### **Customer Pays For:**
- Job posting fee (if enabled): 2,000 TZS
- Subscription (if enabled): 5,000 TZS/month
- Payment to fundi after job completion

### **Fundi Pays For:**
- Application fee (if enabled): 1,000 TZS
- Subscription (if enabled): 5,000 TZS/month

### **Fundi Gets Paid:**
- Job completion payment from customer
- Based on agreed budget in application

---

## 🔔 Notification Types

### **Customer Receives:**
- "New application received" (someone applied to their job)
- "Application withdrawn" (fundi cancelled)
- "Work submitted for review" (fundi finished)
- "Payment processed" (payment went through)

### **Fundi Receives:**
- "Application approved" (got the job!)
- "Application rejected" (didn't get it)
- "New job in your category" (matching job posted)
- "Payment received" (customer paid)
- "New rating received" (customer rated them)

---

## 🎯 Key Takeaways

### **Customers:**
✅ Post jobs & manage them  
✅ Browse fundis to hire  
✅ Review applications & approve  
❌ Don't browse other customers' jobs  
❌ Don't apply to jobs  

### **Fundis:**
✅ Browse all available jobs  
✅ Search & filter jobs  
✅ Apply to multiple jobs  
✅ Manage portfolio  
❌ Don't post jobs  
❌ Don't edit others' jobs  

---

## 📞 Test Accounts

```
CUSTOMER:
Phone: 0654289825
Password: password123
Use for: Posting jobs, hiring fundis

FUNDI:
Phone: 0654289827
Password: password123
Use for: Browsing jobs, applying, portfolio

BOTH ROLES:
Phone: 0754289832
Password: password123
Use for: Testing role switching
```

---

## ✨ Summary

**Customer** = Job Creator (needs help)  
**Fundi** = Service Provider (offers help)

**The platform connects:**
- People who need work done (customers)
- People who do the work (fundis)

**Like a marketplace:**
- Customers list what they need
- Fundis browse listings and apply
- Best match gets hired
- Work gets done
- Everyone's happy! 🎉

---

**Quick Ref Version:** v2.0 (Permission-Corrected)  
**Last Updated:** 2025-10-12  
**Status:** ✅ Production Ready

