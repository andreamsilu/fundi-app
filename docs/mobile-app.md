Got it! Here’s the refined mobile app design documentation where customers and fundis use the same UI, with role-specific actions appearing contextually (e.g., FAB for posting jobs only visible to customers, “Apply” button visible to fundis).

📱 Fundi App – Unified Mobile UI for Fundis & Customers

1. Design Principles
Single UI for both roles to reduce complexity.


Contextual actions based on user role:


Customer: Post jobs, view applications.


Fundi: Apply to jobs, view portfolio.


Clean, intuitive layout with minimal role switching friction.


Consistent navigation, colors, typography, and card designs.



2. Navigation
2.1 Bottom Navigation Bar
Home / Feed: Job listings (all users)


Jobs: My jobs / applied jobs (contextual)


Portfolio: Fundi portfolios (for customers, view only; fundis, manage/upload)


Messages: Chat system


Profile: Account, verification, payment/subscription


2.2 Floating Action Button (FAB)
Visible only for actions allowed per role:


Customer: FAB → Post Job


Fundi: FAB → Add Portfolio (optional)


FAB always contextually visible on relevant screens


2.3 Menu Drawer (Hamburger Menu)
Accessible from top-left


Unified menu items:


Home / Feed


My Jobs


Portfolio


Favorites (Customer) / Achievements (Fundi)


Notifications


Payments / Subscriptions


Settings


Logout



3. Screens
3.1 Authentication & Onboarding
Splash Screen → Onboarding Slides → Signup / Login


Role selection at signup determines contextual actions later


NIDA verification mandatory for fundis


Optional VETA certificate upload



3.2 Home / Feed
Job cards: title, location, brief description, budget, status


Sorted by location & category


For customers, each card shows fundi list & application status


For fundis, card shows “Apply” button if eligible



3.3 Job Posting & Applications
Single Job Detail UI:


Display budget, requirements, attachments, deadline


Customer sees list of fundi applications


Fundi sees “Apply” form with budget breakdown & estimated time


Status Indicators: Pending, In Progress, Completed, Rejected



3.4 Portfolio
Fundis can upload/manage media


Customers can view verified fundi portfolios


Sliding gallery for images/videos


Optional details: skills, time spent, budget



3.5 Messages
Unified chat system


Chat list + conversation screen


Push notifications for new messages



3.6 Profile & Settings
Unified profile screen:


Name, phone, NIDA/VETA, role, job statistics


Subscription/payment info


Notification settings, theme, logout



4. UI/UX Considerations
Single design: Role-based actions appear contextually


FAB & buttons adapt to user role


Job cards and portfolio cards consistent for both users


Color-coded statuses: Pending (yellow), In Progress (blue), Completed (green), Rejected (red)


Location-aware feeds for job/fundi proximity


Push notifications for relevant role-specific events



5. Job Lifecycle
Customer posts job → Fundi sees job → Fundi applies → Customer reviews → Accept/Reject →
Job In Progress → Completed → Customer rates fundi

Unified UI displays relevant actions based on current role and job status


Notifications guide users at each step



6. Technical Considerations
Offline support: Cache job feed, portfolio media


Lazy loading: For images/videos


Media storage: AWS S3 / Firebase Storage


Notifications: Firebase Cloud Messaging


Role-aware FAB & buttons: Conditional rendering based on user type


Budget handling: Display breakdown JSON for each job application



✅ Outcome:
Single UI for all users


Contextual actions prevent confusion


Consistent design reduces learning curve


Both customers and fundis can switch roles seamlessly (optional future feature)





