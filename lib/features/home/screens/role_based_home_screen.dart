import 'package:flutter/material.dart';
import '../../../core/helpers/fundi_navigation_helper.dart';
import '../../../core/guards/role_based_route_guard.dart';
import '../../auth/services/auth_service.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../payment/widgets/payment_status_widget.dart';

/// Role-based home screen that adapts to user roles
/// Shows different content and navigation based on whether user is customer, fundi, or admin
class RoleBasedHomeScreen extends StatefulWidget {
  const RoleBasedHomeScreen({super.key});

  @override
  State<RoleBasedHomeScreen> createState() => _RoleBasedHomeScreenState();
}

class _RoleBasedHomeScreenState extends State<RoleBasedHomeScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userRoles = user.roles;
    final isCustomer = RoleBasedRouteGuard.isCustomer(userRoles.cast<String>());
    final isFundi = RoleBasedRouteGuard.isFundi(userRoles.cast<String>());

    return Scaffold(
      appBar: AppBar(
        title: Text(RoleBasedRouteGuard.getPrimaryRole(userRoles.cast<String>()).toUpperCase()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => FundiNavigationHelper.navigateToPage(
              context, 
              '/notifications',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => FundiNavigationHelper.navigateToPage(
              context, 
              '/profile',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            _buildWelcomeSection(user, userRoles.cast<String>()),
            
            const SizedBox(height: 16),
            
            // Payment status
            PaymentStatusWidget(
              onViewDetails: () => _navigateToPaymentManagement(),
            ),
            
            const SizedBox(height: 24),
            
            // Quick actions based on roles
            if (isCustomer || isFundi) _buildQuickActionsSection(userRoles.cast<String>()),
            
            const SizedBox(height: 24),
            
            // Customer features
            if (isCustomer) _buildCustomerFeaturesSection(),
            
            // Fundi features
            if (isFundi) _buildFundiFeaturesSection(),
            
            // Admin features removed - mobile app doesn't need admin functionality
            
            const SizedBox(height: 24),
            
            // Shared features
            _buildSharedFeaturesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(user, List<String> userRoles) {
    final isCustomer = RoleBasedRouteGuard.isCustomer(userRoles);
    final isFundi = RoleBasedRouteGuard.isFundi(userRoles);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FundiNavigationHelper.getWelcomeMessage(userRoles),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back, ${user.firstName ?? 'User'}!',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          if (isFundi && isCustomer)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'You can both find work and post jobs!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(List<String> userRoles) {
    final quickActions = FundiNavigationHelper.getQuickActions(userRoles);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: quickActions.length,
          itemBuilder: (context, index) {
            final action = quickActions[index];
            return _buildQuickActionCard(action);
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(QuickAction action) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => FundiNavigationHelper.navigateToPage(context, action.route),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                size: 32,
                color: action.color,
              ),
              const SizedBox(height: 8),
              Text(
                action.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          'Post a Job',
          'Find skilled fundis for your projects',
          Icons.add_business,
          Colors.blue,
          '/post-job',
        ),
        _buildFeatureCard(
          'Browse Fundis',
          'Discover talented fundis in your area',
          Icons.search,
          Colors.green,
          '/browse-fundis',
        ),
        _buildFeatureCard(
          'My Jobs',
          'Manage your posted jobs',
          Icons.work,
          Colors.orange,
          '/my-jobs',
        ),
      ],
    );
  }

  Widget _buildFundiFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fundi Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          'Job Applications',
          'Apply to available jobs',
          Icons.assignment,
          Colors.purple,
          '/job-applications',
        ),
        _buildFeatureCard(
          'My Portfolio',
          'Showcase your work',
          Icons.photo_library,
          Colors.teal,
          '/my-portfolio',
        ),
        _buildFeatureCard(
          'Fundi Profile',
          'Update your professional profile',
          Icons.person,
          Colors.indigo,
          '/fundi-profile',
        ),
      ],
    );
  }

  // Admin features removed - mobile app doesn't need admin functionality

  Widget _buildSharedFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          'Profile',
          'Manage your profile information',
          Icons.person_outline,
          Colors.blueGrey,
          '/profile',
        ),
        _buildFeatureCard(
          'Settings',
          'App preferences and configuration',
          Icons.settings_outlined,
          Colors.grey,
          '/settings',
        ),
        _buildFeatureCard(
          'Notifications',
          'View your notifications',
          Icons.notifications,
          Colors.orange,
          '/notifications',
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => FundiNavigationHelper.navigateToPage(context, route),
      ),
    );
  }

  void _navigateToPaymentPlans() {
    // TODO: Navigate to payment plans screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment plans screen - Coming soon!'),
      ),
    );
  }

  void _navigateToPaymentManagement() {
    // TODO: Navigate to payment management screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment management screen - Coming soon!'),
      ),
    );
  }
}
