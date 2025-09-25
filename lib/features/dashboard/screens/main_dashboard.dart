import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../portfolio/providers/portfolio_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/animated_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../job/screens/job_list_screen.dart';
import '../../portfolio/screens/portfolio_screen.dart';
import '../../messaging/screens/chat_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../help/screens/help_screen.dart';
import '../../fundi_application/screens/fundi_application_screen.dart';
import '../../feeds/screens/fundi_feed_screen.dart';
import '../services/dashboard_service.dart';
import '../models/dashboard_model.dart';
import 'placeholder_screen.dart';

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
    try {
      _fabAnimationController.dispose();
    } catch (e) {
      print('Error disposing fab animation controller: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Scaffold(
      drawer: _buildDrawer(authService),
      appBar: _buildAppBar(authService),
      body: IndexedStack(
        index: _currentIndex,
        children: _getScreens(authService),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(authService),
      floatingActionButton: _buildFloatingActionButton(authService),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Get screens based on user role (customers and fundis only)
  List<Widget> _getScreens(AuthService authService) {
    if (authService.currentUser?.isCustomer ?? false) {
      return [
        const JobListScreen(
          title: 'Available Jobs',
          showAppBar: false,
        ), // Home - Available jobs
        const FundiFeedScreen(), // Find Fundis
        const JobListScreen(
          title: 'My Jobs',
          showFilterButton: false,
          showAppBar: false,
        ), // My Jobs - Posted jobs
        const ProfileScreen(showAppBar: false), // Profile
      ];
    } else {
      // Fundi
      return [
        const JobListScreen(
          title: 'Find Jobs',
          showAppBar: false,
        ), // Home - Available jobs
        const JobListScreen(
          title: 'Applied Jobs',
          showFilterButton: false,
          showAppBar: false,
        ), // Applied Jobs - Applied jobs
        const ProfileScreen(showAppBar: false), // Profile
      ];
    }
  }

  /// Build dynamic AppBar based on current page
  PreferredSizeWidget _buildAppBar(AuthService authService) {
    String title;

    switch (_currentIndex) {
      case 0:
        if (authService.currentUser?.isCustomer ?? false) {
          title = 'Available Jobs';
        } else {
          title = 'Find Jobs';
        }
        break;
      case 1:
        if (authService.currentUser?.isCustomer ?? false) {
          title = 'Find Fundis';
        } else {
          title = 'Applied Jobs';
        }
        break;
      case 2:
        if (authService.currentUser?.isCustomer ?? false) {
          title = 'My Jobs';
        } else {
          title = 'Profile';
        }
        break;
      case 3:
        title = 'Profile';
        break;
      default:
        title = 'Fundi';
    }

    return AppBar(
      title: Text(title),
      backgroundColor: Colors.transparent,
      elevation: 0,
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
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomNavigationBar(AuthService authService) {
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
        items: _getBottomNavItems(authService),
      ),
    );
  }

  /// Get bottom navigation items based on user role
  List<BottomNavigationBarItem> _getBottomNavItems(AuthService authService) {
    if (authService.currentUser?.isCustomer ?? false) {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Find Fundis',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          activeIcon: Icon(Icons.work),
          label: 'My Jobs',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      // Fundi
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          activeIcon: Icon(Icons.search),
          label: 'Find Jobs',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Applied',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }

  /// Build drawer menu with additional options
  Widget _buildDrawer(AuthService authService) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          _buildDrawerHeader(authService),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Portfolio Section
                _buildDrawerSection(
                  title: 'Portfolio',
                  children: [
                    _buildDrawerItem(
                      icon: Icons.work_outline,
                      title: 'View Portfolio',
                      onTap: () => _navigateToPortfolio(),
                    ),
                    if (authService.currentUser?.isFundi ?? false) ...[
                      _buildDrawerItem(
                        icon: Icons.add_circle_outline,
                        title: 'Add Portfolio',
                        onTap: () => _navigateToAddPortfolio(),
                      ),
                    ],
                  ],
                ),

                const Divider(),

                // Feed Section
                _buildDrawerSection(
                  title: 'Discover',
                  children: [
                    if (authService.currentUser?.isCustomer ?? false) ...[
                      _buildDrawerItem(
                        icon: Icons.people_outline,
                        title: 'Find Fundis',
                        onTap: () => _navigateToFundiFeed(),
                      ),
                    ],
                    // Removed 'Find Jobs' from drawer as requested
                  ],
                ),

                const Divider(),

                // Communication Section
                _buildDrawerSection(
                  title: 'Communication',
                  children: [
                    _buildDrawerItem(
                      icon: Icons.message_outlined,
                      title: 'Messages',
                      onTap: () => _navigateToMessages(),
                    ),
                    _buildDrawerItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () => _navigateToNotifications(),
                    ),
                  ],
                ),

                const Divider(),

                // Work Approval Section (for customers only)
                if (authService.currentUser?.isCustomer ?? false) ...[
                  _buildDrawerSection(
                    title: 'Work Management',
                    children: [
                      _buildDrawerItem(
                        icon: Icons.approval,
                        title: 'Work Approval',
                        onTap: () => _navigateToWorkApproval(),
                      ),
                    ],
                  ),
                  const Divider(),
                ],

                const Divider(),

                // Fundi Application Section (for customers only)
                if (authService.currentUser?.isCustomer ?? false) ...[
                  _buildDrawerSection(
                    title: 'Become a Fundi',
                    children: [
                      _buildDrawerItem(
                        icon: Icons.build_circle,
                        title: 'Apply to Become Fundi',
                        onTap: () => _navigateToFundiApplication(),
                      ),
                    ],
                  ),
                  const Divider(),
                ],

                // Settings Section
                _buildDrawerSection(
                  title: 'Settings',
                  children: [
                    _buildDrawerItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () => _navigateToSettings(),
                    ),
                    _buildDrawerItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () => _navigateToHelp(),
                    ),
                  ],
                ),

                const Divider(),

                // Logout
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () => _handleLogout(authService),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build drawer header with user info
  Widget _buildDrawerHeader(AuthService authService) {
    final user = authService.currentUser;
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentGreen,
            AppTheme.accentGreen.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      accountName: Text(
        user?.fullName ?? 'User',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      accountEmail: Text(
        user?.email ?? 'user@example.com',
        style: const TextStyle(fontSize: 14, color: Colors.white70),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          user?.firstName?.substring(0, 1).toUpperCase() ?? 'U',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.accentGreen,
          ),
        ),
      ),
    );
  }

  /// Build drawer section with title
  Widget _buildDrawerSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.mediumGray,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  /// Build drawer item
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppTheme.mediumGray,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : AppTheme.darkGray,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
    );
  }

  /// Build floating action button based on user role
  Widget? _buildFloatingActionButton(AuthService authService) {
    if (authService.currentUser?.isCustomer ?? false) {
      return FloatingActionButton(
        heroTag: "main_dashboard_fab_customer",
        onPressed: () {
          // Navigate to create job screen
          _navigateToCreateJob();
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: AppTheme.white),
      );
    } else {
      // Fundi
      return FloatingActionButton(
        heroTag: "main_dashboard_fab_fundi",
        onPressed: () {
          // Navigate to add portfolio screen
          _navigateToAddPortfolio();
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add_a_photo, color: AppTheme.white),
      );
    }
  }

  /// Navigate to create job screen
  void _navigateToCreateJob() {
    print('MainDashboard: Navigating to create job screen');
    try {
      Navigator.pushNamed(context, '/create-job');
      print('MainDashboard: Navigation successful');
    } catch (e) {
      print('MainDashboard: Navigation error: $e');
    }
  }

  /// Navigate to add portfolio screen
  void _navigateToAddPortfolio() {
    print('MainDashboard: Navigating to create portfolio screen');
    try {
      Navigator.pushNamed(context, '/create-portfolio');
      print('MainDashboard: Portfolio navigation successful');
    } catch (e) {
      print('MainDashboard: Portfolio navigation error: $e');
    }
  }

  /// Navigate to portfolio screen
  void _navigateToPortfolio() {
    print('MainDashboard: Navigating to portfolio screen');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => PortfolioProvider(),
          child: const PortfolioScreen(),
        ),
      ),
    );
    print('MainDashboard: Portfolio navigation successful');
  }

  /// Navigate to messages screen
  void _navigateToMessages() {
    try {
      print('MainDashboard: Navigating to messages screen');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatListScreen()),
      );
      print('MainDashboard: Messages navigation successful');
    } catch (e) {
      print('MainDashboard: Messages navigation error: $e');
      // Show placeholder screen instead of error
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PlaceholderScreen(
            title: 'Messages',
            message:
                'Messaging feature is coming soon! You\'ll be able to chat with fundis and customers here.',
            icon: Icons.message_outlined,
          ),
        ),
      );
    }
  }

  /// Navigate to notifications screen
  void _navigateToNotifications() {
    try {
      print('MainDashboard: Navigating to notifications screen');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
      );
      print('MainDashboard: Notifications navigation successful');
    } catch (e) {
      print('MainDashboard: Notifications navigation error: $e');
      // Show placeholder screen instead of error
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PlaceholderScreen(
            title: 'Notifications',
            message:
                'Notifications feature is coming soon! You\'ll receive updates about jobs and messages here.',
            icon: Icons.notifications_outlined,
          ),
        ),
      );
    }
  }

  /// Navigate to settings screen
  void _navigateToSettings() {
    try {
      print('MainDashboard: Navigating to settings screen');
      Navigator.pushNamed(context, '/settings');
      print('MainDashboard: Settings navigation successful');
    } catch (e) {
      print('MainDashboard: Settings navigation error: $e');
      // Show placeholder screen instead of error
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PlaceholderScreen(
            title: 'Settings',
            message:
                'Settings feature is coming soon! You\'ll be able to customize your app preferences here.',
            icon: Icons.settings_outlined,
          ),
        ),
      );
    }
  }

  /// Navigate to help screen
  void _navigateToHelp() {
    try {
      print('MainDashboard: Navigating to help screen');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HelpScreen()),
      );
      print('MainDashboard: Help navigation successful');
    } catch (e) {
      print('MainDashboard: Help navigation error: $e');
      // Show placeholder screen instead of error
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PlaceholderScreen(
            title: 'Help & Support',
            message:
                'Help feature is coming soon! You\'ll find FAQs and support options here.',
            icon: Icons.help_outline,
          ),
        ),
      );
    }
  }

  /// Navigate to fundi application screen
  void _navigateToFundiApplication() {
    try {
      print('MainDashboard: Navigating to fundi application screen');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FundiApplicationScreen()),
      );
      print('MainDashboard: Fundi application navigation successful');
    } catch (e) {
      print('MainDashboard: Fundi application navigation error: $e');
      // Show placeholder screen instead of error
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PlaceholderScreen(
            title: 'Become a Fundi',
            message:
                'Fundi application feature is coming soon! You\'ll be able to apply to become a fundi here.',
            icon: Icons.build_circle,
          ),
        ),
      );
    }
  }

  /// Navigate to fundi feed screen
  void _navigateToFundiFeed() {
    // Switch to the existing bottom tab to avoid duplicate screens
    setState(() {
      _currentIndex = 1; // Customers: index 1 is Find Fundis
    });
  }

  /// Navigate to job feed screen
  void _navigateToJobFeed() {
    try {
      print('MainDashboard: Navigating to job feed screen');
      Navigator.pushNamed(context, '/job-feed');
      print('MainDashboard: Job feed navigation successful');
    } catch (e) {
      print('MainDashboard: Job feed navigation error: $e');
      // Show placeholder screen instead of error
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PlaceholderScreen(
            title: 'Job Feed',
            message:
                'Job feed feature is coming soon! You\'ll be able to browse available jobs here.',
            icon: Icons.work_outline,
          ),
        ),
      );
    }
  }

  /// Navigate to work approval screen
  void _navigateToWorkApproval() {
    try {
      print('MainDashboard: Navigating to work approval screen');
      Navigator.pushNamed(context, '/work-approval');
      print('MainDashboard: Work approval navigation successful');
    } catch (e) {
      print('MainDashboard: Work approval navigation error: $e');
      // Show placeholder screen instead of error
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PlaceholderScreen(
            title: 'Work Approval',
            message:
                'Work approval feature is coming soon! You\'ll be able to approve completed work here.',
            icon: Icons.approval,
          ),
        ),
      );
    }
  }

  /// Handle logout
  void _handleLogout(AuthService authService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authService.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
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
    try {
      _fadeController.dispose();
    } catch (e) {
      print('Error disposing fade controller: $e');
    }
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
    final authService = AuthService();
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildBody(context, authService),
    );
  }

  Widget _buildBody(BuildContext context, AuthService authService) {
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
            _buildQuickStats(context, authService),
            const SizedBox(height: 24),
            _buildQuickActions(context, authService),
            const SizedBox(height: 24),
            _buildRecentActivity(context, authService),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, AuthService authService) {
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

  Widget _buildQuickActions(BuildContext context, AuthService authService) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (authService.currentUser?.isCustomer ?? false) ...[
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
          ] else if (authService.currentUser?.isFundi ?? false) ...[
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

  Widget _buildRecentActivity(BuildContext context, AuthService authService) {
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
