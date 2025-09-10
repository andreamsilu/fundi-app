import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/animated_card.dart';
import '../../job/screens/job_list_screen.dart';
import '../../portfolio/screens/portfolio_screen.dart';
import '../../messaging/screens/chat_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../notifications/screens/notifications_screen.dart';

/// Main dashboard screen with role-based navigation
/// Provides different views for customers, fundis, and admins
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _getScreens(authProvider),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(authProvider),
          floatingActionButton: _buildFloatingActionButton(authProvider),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  /// Get screens based on user role
  List<Widget> _getScreens(AuthProvider authProvider) {
    if (authProvider.isCustomer) {
      return [
        const JobListScreen(), // Home - Available jobs
        const JobListScreen(), // My Jobs - Posted jobs
        const PortfolioScreen(), // Portfolio - View fundi portfolios
        const ChatListScreen(), // Messages
        const ProfileScreen(userId: '',), // Profile
      ];
    } else if (authProvider.isFundi) {
      return [
        const JobListScreen(), // Home - Available jobs
        const JobListScreen(), // Applied Jobs - Applied jobs
        const PortfolioScreen(), // Portfolio - Manage portfolio
        const ChatListScreen(), // Messages
        const ProfileScreen(userId: '',), // Profile
      ];
    } else {
      // Admin
      return [
        const JobListScreen(), // Home - All jobs
        const JobListScreen(), // Jobs - Job management
        const PortfolioScreen(), // Portfolio - All portfolios
        const ChatListScreen(), // Messages
        const ProfileScreen(userId: '',), // Profile
      ];
    }
  }

  /// Build bottom navigation bar
  Widget _buildBottomNavigationBar(AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.white,
        selectedItemColor: AppTheme.accentGreen,
        unselectedItemColor: AppTheme.mediumGray,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: _getBottomNavItems(authProvider),
      ),
    );
  }

  /// Get bottom navigation items based on user role
  List<BottomNavigationBarItem> _getBottomNavItems(AuthProvider authProvider) {
    if (authProvider.isCustomer) {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          activeIcon: Icon(Icons.work),
          label: 'My Jobs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          activeIcon: Icon(Icons.work),
          label: 'Portfolio',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          activeIcon: Icon(Icons.message),
          label: 'Messages',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else if (authProvider.isFundi) {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Applied',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          activeIcon: Icon(Icons.work),
          label: 'Portfolio',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          activeIcon: Icon(Icons.message),
          label: 'Messages',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      // Admin
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          activeIcon: Icon(Icons.work),
          label: 'Jobs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          activeIcon: Icon(Icons.work),
          label: 'Portfolio',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          activeIcon: Icon(Icons.message),
          label: 'Messages',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }

  /// Build floating action button based on user role
  Widget? _buildFloatingActionButton(AuthProvider authProvider) {
    if (authProvider.isCustomer) {
      return FloatingActionButton(
        onPressed: () {
          // Navigate to create job screen
          _navigateToCreateJob();
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: AppTheme.white),
      );
    } else if (authProvider.isFundi) {
      return FloatingActionButton(
        onPressed: () {
          // Navigate to add portfolio screen
          _navigateToAddPortfolio();
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add_a_photo, color: AppTheme.white),
      );
    }
    return null; // Admin doesn't need FAB
  }

  /// Navigate to create job screen
  void _navigateToCreateJob() {
    // TODO: Implement navigation to create job screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create Job feature coming soon!'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }

  /// Navigate to add portfolio screen
  void _navigateToAddPortfolio() {
    // TODO: Implement navigation to add portfolio screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Portfolio feature coming soon!'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }
}

/// Dashboard home screen with role-specific content
class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_getWelcomeMessage(authProvider)),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickStats(context, authProvider),
                const SizedBox(height: 24),
                _buildQuickActions(context, authProvider),
                const SizedBox(height: 24),
                _buildRecentActivity(context, authProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getWelcomeMessage(AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return 'Welcome';

    final timeOfDay = DateTime.now().hour;
    String greeting;
    if (timeOfDay < 12) {
      greeting = 'Good Morning';
    } else if (timeOfDay < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return '$greeting, ${user.firstName}';
  }

  Widget _buildQuickStats(BuildContext context, AuthProvider authProvider) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Stats', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Active Jobs',
                  '12',
                  Icons.work_outline,
                  AppTheme.infoColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Completed',
                  '45',
                  Icons.check_circle_outline,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Earnings',
                  '2.5M TZS',
                  Icons.attach_money_outlined,
                  AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Rating',
                  '4.8',
                  Icons.star_outline,
                  AppTheme.accentGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGray),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AuthProvider authProvider) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (authProvider.isCustomer) ...[
            _buildActionButton(
              context,
              'Post New Job',
              'Find skilled fundis for your project',
              Icons.add_circle_outline,
              () {
                // TODO: Navigate to create job
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              'Browse Fundis',
              'Explore verified craftsmen',
              Icons.search,
              () {
                // TODO: Navigate to fundi search
              },
            ),
          ] else if (authProvider.isFundi) ...[
            _buildActionButton(
              context,
              'Find Jobs',
              'Discover new opportunities',
              Icons.search,
              () {
                // TODO: Navigate to job search
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              'Update Portfolio',
              'Showcase your best work',
              Icons.add_a_photo,
              () {
                // TODO: Navigate to portfolio update
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightGray.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGray),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppTheme.mediumGray, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, AuthProvider authProvider) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            context,
            'New job application received',
            '2 hours ago',
            Icons.person_add,
            AppTheme.infoColor,
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            context,
            'Job completed successfully',
            '1 day ago',
            Icons.check_circle,
            AppTheme.successColor,
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            context,
            'Payment received',
            '3 days ago',
            Icons.payment,
            AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                time,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGray),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
