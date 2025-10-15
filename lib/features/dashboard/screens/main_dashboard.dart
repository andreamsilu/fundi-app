import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/animated_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../job/screens/job_list_screen.dart';
// Messaging feature removed - not implemented in API
import '../../profile/screens/profile_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../help/screens/help_screen.dart';
import '../../fundi_application/screens/fundi_application_screen.dart';
import '../../feeds/screens/fundi_feed_screen.dart';
import '../../feeds/screens/comprehensive_fundi_profile_screen.dart';
import '../services/dashboard_service.dart';
import '../models/dashboard_model.dart';
import '../../../core/utils/role_guard.dart';
import '../../auth/models/user_model.dart';

/// Main dashboard screen with role-based navigation
/// Provides different views for customers and fundis
/// Note: Admin not supported on mobile - use web admin panel
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

    // Check for route arguments to auto-switch tabs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _handleRouteArguments(args);
      }
    });
  }

  /// Handle route arguments for auto-navigation (using role-based navigation)
  void _handleRouteArguments(Map<String, dynamic> args) {
    final authService = AuthService();
    final userRole =
        authService.currentUser?.roles.firstOrNull ?? UserRole.customer;

    // Switch to Applied Jobs tab (for fundis after applying)
    if (args['switchToAppliedJobs'] == true && userRole == UserRole.fundi) {
      setState(() {
        _currentIndex = 1; // Applied Jobs tab for fundis (index 1)
      });
    }
    // Switch to My Jobs tab (for customers after posting)
    else if (args['switchToMyJobs'] == true && userRole == UserRole.customer) {
      setState(() {
        _currentIndex = 1; // My Jobs tab for customers (now index 1)
      });
    }
    // Switch to specific tab index
    else if (args['initialTab'] != null) {
      setState(() {
        _currentIndex = args['initialTab'] as int;
      });
    }
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
  /// Note: Admin role not supported on mobile - use web admin panel
  List<Widget> _getScreens(AuthService authService) {
    final userRole =
        authService.currentUser?.roles.firstOrNull ?? UserRole.customer;

    switch (userRole) {
      case UserRole.customer:
        // CUSTOMER: Can't browse all jobs, only see their own posted jobs
        return [
          const FundiFeedScreen(), // Find Fundis to hire (Tab 0)
          const JobListScreen(
            title: 'My Jobs',
            showFilterButton: false,
            showAppBar: false,
          ), // Their posted jobs (Tab 1)
          const ProfileScreen(showAppBar: false), // Profile (Tab 2)
        ];

      case UserRole.fundi:
        // FUNDI: Can browse all available jobs to find work
        return [
          const JobListScreen(
            title: 'Available Jobs',
            showAppBar: false,
          ), // Home - Browse ALL available jobs
          const JobListScreen(
            title: 'Applied Jobs',
            showFilterButton: false,
            showAppBar: false,
          ), // My Applications
          const ProfileScreen(showAppBar: false), // Profile
        ];

      case UserRole.admin:
        // Admin not supported on mobile - fallback to customer view
        return [
          const FundiFeedScreen(), // Find Fundis (Tab 0)
          const JobListScreen(
            title: 'My Jobs',
            showFilterButton: false,
            showAppBar: false,
          ), // My Jobs (Tab 1)
          const ProfileScreen(showAppBar: false), // Profile (Tab 2)
        ];
    }
  }

  /// Build dynamic AppBar based on current page (using RoleGuard)
  PreferredSizeWidget _buildAppBar(AuthService authService) {
    // Get user role
    final userRole =
        authService.currentUser?.roles.firstOrNull ?? UserRole.customer;

    // Get bottom nav items from RoleGuard
    final bottomNavItems = RoleGuard.getBottomNavItemsForRole(userRole);

    // Get title from current bottom nav item
    String title = 'Dashboard';
    if (_currentIndex < bottomNavItems.length) {
      title = bottomNavItems[_currentIndex].label;
    }

    return AppBar(
      title: Text(title),
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
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

  /// Get bottom navigation items based on user role (using RoleGuard)
  List<BottomNavigationBarItem> _getBottomNavItems(AuthService authService) {
    // Get user role from AuthService
    final userRole =
        authService.currentUser?.roles.firstOrNull ?? UserRole.customer;

    // Get bottom nav items from RoleGuard based on role
    final bottomNavItems = RoleGuard.getBottomNavItemsForRole(userRole);

    // Convert BottomNavItem to BottomNavigationBarItem
    return bottomNavItems.map((item) {
      return BottomNavigationBarItem(
        icon: Icon(item.icon),
        activeIcon: Icon(item.activeIcon),
        label: item.label,
      );
    }).toList();
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
                // Portfolio Section - Only for Fundis (Portfolio is part of profile)
                if (authService.currentUser?.isFundi ?? false) ...[
                  _buildDrawerSection(
                    title: 'My Profile',
                    children: [
                      _buildDrawerItem(
                        icon: Icons.person_outline,
                        title: 'View My Profile',
                        onTap: () => _navigateToMyProfile(),
                      ),
                    ],
                  ),
                  const Divider(),
                ],

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

                // Payment Section
                _buildDrawerSection(
                  title: 'Payments',
                  children: [
                    _buildDrawerItem(
                      icon: Icons.card_membership,
                      title: 'Payment Plans',
                      onTap: () => _navigateToPaymentPlans(),
                    ),
                    _buildDrawerItem(
                      icon: Icons.history,
                      title: 'Payment History',
                      onTap: () => _navigateToPaymentHistory(),
                    ),
                  ],
                ),

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

                // Bottom spacing to prevent hiding by navigation buttons
                const SizedBox(height: 80),
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

  /// Build floating action button based on user role (using RoleGuard)
  Widget? _buildFloatingActionButton(AuthService authService) {
    final userRole =
        authService.currentUser?.roles.firstOrNull ?? UserRole.customer;

    // Only customers get FAB for posting jobs
    if (userRole == UserRole.customer) {
      return FloatingActionButton(
        heroTag: "main_dashboard_fab_customer",
        onPressed: _navigateToCreateJob,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: AppTheme.white),
        tooltip: 'Post a Job',
      );
    }

    // No FAB for fundis and admins
    return null;
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

  /// Navigate to current user's profile (fundis can manage portfolio here)
  void _navigateToMyProfile() {
    final authService = AuthService();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not found')));
      return;
    }

    print('MainDashboard: Navigating to my profile');
    Navigator.pushNamed(
      context,
      '/fundi-profile',
      arguments: {
        'fundi': {
          'id': currentUser.id,
          'full_name': currentUser.fullName,
          'email': currentUser.email,
          'role': currentUser.roles.first.value,
        },
      },
    );
    print('MainDashboard: Profile navigation successful');
  }

  /// Navigate to messages screen
  void _navigateToMessages() {
    try {
      print('MainDashboard: Navigating to messages screen');
      Navigator.pushNamed(context, '/messages');
    } catch (e) {
      print('MainDashboard: Messages navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Messaging feature is coming soon!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Navigate to notifications screen
  void _navigateToNotifications() {
    try {
      print('MainDashboard: Navigating to notifications screen');
      Navigator.pushNamed(context, '/notifications');
      print('MainDashboard: Notifications navigation successful');
    } catch (e) {
      print('MainDashboard: Notifications navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open notifications at this time'),
          backgroundColor: Colors.red,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open settings at this time'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Navigate to help screen
  void _navigateToHelp() {
    try {
      print('MainDashboard: Navigating to help screen');
      Navigator.pushNamed(context, '/help');
      print('MainDashboard: Help navigation successful');
    } catch (e) {
      print('MainDashboard: Help navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open help at this time'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Navigate to fundi application screen
  void _navigateToFundiApplication() {
    try {
      print('MainDashboard: Navigating to fundi application screen');
      Navigator.pushNamed(context, '/fundi-application');
      print('MainDashboard: Fundi application navigation successful');
    } catch (e) {
      print('MainDashboard: Fundi application navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open fundi application at this time'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Navigate to fundi feed screen
  void _navigateToFundiFeed() {
    // Switch to the existing bottom tab to avoid duplicate screens
    setState(() {
      _currentIndex = 0; // Customers: index 0 is Find Fundis (now first tab)
    });
    Navigator.pop(context); // Close drawer
  }

  /// Navigate to work approval screen
  void _navigateToWorkApproval() {
    try {
      print('MainDashboard: Navigating to work approval screen');
      Navigator.pushNamed(context, '/work-approval');
      print('MainDashboard: Work approval navigation successful');
    } catch (e) {
      print('MainDashboard: Work approval navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open work approval at this time'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Navigate to payment plans screen
  void _navigateToPaymentPlans() {
    try {
      print('MainDashboard: Navigating to payment plans screen');
      Navigator.pushNamed(context, '/payment-plans');
      print('MainDashboard: Payment plans navigation successful');
    } catch (e) {
      print('MainDashboard: Payment plans navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open payment plans at this time'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Navigate to payment history screen
  void _navigateToPaymentHistory() {
    try {
      print('MainDashboard: Navigating to payment history screen');
      Navigator.pushNamed(context, '/payment-management');
      print('MainDashboard: Payment history navigation successful');
    } catch (e) {
      print('MainDashboard: Payment history navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open payment history at this time'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handle logout
  void _handleLogout(AuthService authService) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Close dialog first
                Navigator.of(dialogContext).pop();

                // Perform logout
                await authService.logout();

                // Navigate to login using the main widget's context, not dialog context
                if (mounted && context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
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
      // Dashboard stats and activity endpoints removed - using empty data
      if (mounted) {
        setState(() {
          _dashboardData = DashboardModel.empty();
          _recentActivity = [];
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
                Navigator.pushNamed(context, '/fundi-feed');
              },
            ),
          ] else if (authService.currentUser?.isFundi ?? false) ...[
            _buildActionButton(
              context,
              'Available Jobs',
              'Discover new opportunities',
              Icons.work_outline,
              () {
                Navigator.pushNamed(context, '/job-feed');
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              'Update Portfolio',
              'Showcase your best work',
              Icons.add_a_photo,
              () {
                // Navigate to profile (portfolio is part of profile for fundis)
                Navigator.pushNamed(context, '/profile');
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
