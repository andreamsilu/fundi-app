import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/animated_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../job/screens/job_list_screen.dart';
import '../../portfolio/screens/portfolio_screen.dart';
import '../../messaging/screens/chat_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../services/dashboard_service.dart';
import '../models/dashboard_model.dart';

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
        const ProfileScreen(userId: ''), // Profile
      ];
    } else if (authProvider.isFundi) {
      return [
        const JobListScreen(), // Home - Available jobs
        const JobListScreen(), // Applied Jobs - Applied jobs
        const PortfolioScreen(), // Portfolio - Manage portfolio
        const ChatListScreen(), // Messages
        const ProfileScreen(userId: ''), // Profile
      ];
    } else {
      // Admin
      return [
        const JobListScreen(), // Home - All jobs
        const JobListScreen(), // Jobs - Job management
        const PortfolioScreen(), // Portfolio - All portfolios
        const ChatListScreen(), // Messages
        const ProfileScreen(userId: ''), // Profile
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
            color: Colors.black.withValues(alpha: 0.1),
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
    Navigator.pushNamed(context, '/create-job');
  }

  /// Navigate to add portfolio screen
  void _navigateToAddPortfolio() {
    Navigator.pushNamed(context, '/create-portfolio');
  }
}

/// Dashboard home screen with role-specific content
class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  DashboardModel? _dashboardData;
  List<ActivityItem> _recentActivity = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDashboardData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load dashboard stats and recent activity in parallel
      final results = await Future.wait([
        DashboardService().getDashboardStats(),
        DashboardService().getRecentActivity(limit: 5),
      ]);

      final dashboardResult = results[0] as DashboardResult;
      final activityResult = results[1] as ActivityResult;

      if (mounted) {
        setState(() {
          if (dashboardResult.success) {
            _dashboardData = dashboardResult.dashboard;
          } else {
            _errorMessage = dashboardResult.message;
          }

          if (activityResult.success) {
            _recentActivity = activityResult.activities ?? [];
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load dashboard data';
          _isLoading = false;
        });
      }
    }
  }

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
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildBody(context, authProvider),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AuthProvider authProvider) {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Loading dashboard...', size: 50),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ErrorBanner(
              message: _errorMessage!,
              onDismiss: () {
                setState(() {
                  _errorMessage = null;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
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
    final dashboard = _dashboardData ?? DashboardModel.empty();

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
                  dashboard.activeJobs.toString(),
                  Icons.work_outline,
                  AppTheme.infoColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Completed',
                  dashboard.completedJobs.toString(),
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
                  _formatEarnings(dashboard.totalEarnings),
                  Icons.attach_money_outlined,
                  AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Rating',
                  dashboard.averageRating.toStringAsFixed(1),
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

  String _formatEarnings(double earnings) {
    if (earnings >= 1000000) {
      return '${(earnings / 1000000).toStringAsFixed(1)}M TZS';
    } else if (earnings >= 1000) {
      return '${(earnings / 1000).toStringAsFixed(1)}K TZS';
    } else {
      return '${earnings.toStringAsFixed(0)} TZS';
    }
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
          color: AppTheme.lightGray.withValues(alpha: 0.5),
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
          if (_recentActivity.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No recent activity',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
                textAlign: TextAlign.center,
              ),
            )
          else
            ..._recentActivity.map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildActivityItem(
                  context,
                  activity.title,
                  activity.timeAgo,
                  _getActivityIcon(activity.type),
                  _getActivityColor(activity.type),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'job_application':
        return Icons.person_add;
      case 'job_completed':
        return Icons.check_circle;
      case 'payment':
        return Icons.payment;
      case 'message':
        return Icons.message;
      case 'notification':
        return Icons.notifications;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'job_application':
        return AppTheme.infoColor;
      case 'job_completed':
        return AppTheme.successColor;
      case 'payment':
        return AppTheme.warningColor;
      case 'message':
        return AppTheme.primaryGreen;
      case 'notification':
        return AppTheme.accentGreen;
      default:
        return AppTheme.mediumGray;
    }
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
            color: color.withValues(alpha: 0.1),
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
