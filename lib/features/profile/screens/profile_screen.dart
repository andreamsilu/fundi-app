import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import 'profile_edit_screen.dart';
import '../../fundi_application/screens/fundi_application_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../../shared/widgets/button_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../portfolio/providers/portfolio_provider.dart';
import '../../portfolio/models/portfolio_model.dart';
import '../../portfolio/screens/portfolio_details_screen.dart';
import '../../portfolio/screens/portfolio_creation_screen.dart';

/// Profile screen displaying user information
/// Shows user details and provides access to edit functionality
/// Integrates portfolio viewing for fundi users
class ProfileScreen extends StatefulWidget {
  final String?
  userId; // Make userId optional since we get current user profile
  final bool showAppBar; // Control whether to show AppBar

  const ProfileScreen({super.key, this.userId, this.showAppBar = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  ProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Update FAB visibility when tab changes
      if (mounted) {
        setState(() {});
      }
    });
    _setupAnimations();
    _loadProfile();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('ProfileScreen: Loading current user profile');

      // First try to get profile from ProfileService
      ProfileModel? profile = await ProfileService().getProfile(
        widget.userId ?? '',
      );

      // If that fails, try to get current user from AuthService
      if (profile == null) {
        print('ProfileScreen: ProfileService failed, trying AuthService');
        final authService = AuthService();
        final currentUser = authService.currentUser;

        if (currentUser != null) {
          // Create a basic profile from current user data
          final fullName = currentUser.fullName ?? '';
          final nameParts = fullName.split(' ');
          final firstName = nameParts.isNotEmpty ? nameParts.first : '';
          final lastName = nameParts.length > 1
              ? nameParts.sublist(1).join(' ')
              : '';

          profile = ProfileModel(
            id: currentUser.id,
            firstName: firstName,
            lastName: lastName,
            email: currentUser.email ?? '',
            phoneNumber: currentUser.phone,
            role: currentUser.roles.isNotEmpty
                ? currentUser.roles.first as UserRole
                : UserRole.customer,
            status: UserStatus.active,
            profileImageUrl: currentUser.profileImageUrl,
            bio: null, // Will be filled from profile service
            location: null, // Will be filled from profile service
            skills: [], // Will be filled from profile service
            languages: [], // Will be filled from profile service
            createdAt: currentUser.createdAt ?? DateTime.now(),
            updatedAt: currentUser.updatedAt ?? DateTime.now(),
          );
        }
      }

      print(
        'ProfileScreen: Profile loaded: ${profile != null ? 'Success' : 'Failed'}',
      );

      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
          if (profile == null) {
            _errorMessage = 'Unable to load profile. Please try again.';
          }
        });

        // Load portfolio if user is a fundi
        if (profile != null && profile.isFundi) {
          _loadPortfolio();
        }
      }
    } catch (e) {
      print('ProfileScreen: Profile loading error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  /// Load portfolio items for the current fundi user
  Future<void> _loadPortfolio() async {
    try {
      if (_profile == null || !_profile!.isFundi) return;

      final portfolioProvider = Provider.of<PortfolioProvider>(
        context,
        listen: false,
      );
      await portfolioProvider.loadPortfolios(
        fundiId: _profile!.id,
        refresh: true,
      );
    } catch (e) {
      print('Error loading portfolio: $e');
    }
  }

  Future<void> _editProfile() async {
    if (_profile == null) {
      print('ProfileScreen: Cannot edit - profile is null');
      return;
    }

    try {
      final result = await Navigator.push<ProfileModel>(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileEditScreen(profile: _profile!),
        ),
      );

      if (result != null && mounted) {
        setState(() {
          _profile = result;
        });
      }
    } catch (e) {
      print('ProfileScreen: Edit profile error: $e');
    }
  }

  void _navigateToFundiApplication() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FundiApplicationScreen()),
    );
  }

  Widget _buildFundiApplicationStatus() {
    // TODO: Implement fundi application status checking
    // This would check if the user has already applied to become a fundi
    // and show the current status (pending, approved, rejected)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.mediumGray, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Apply to become a fundi and start earning from your skills',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGray),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isFundi = _profile?.isFundi ?? false;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Profile'),
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit),
                ),
              ],
              bottom: isFundi
                  ? TabBar(
                      controller: _tabController,
                      indicatorColor: context.primaryColor,
                      labelColor: context.primaryColor,
                      unselectedLabelColor: AppTheme.mediumGray,
                      tabs: const [
                        Tab(
                          text: 'Profile',
                          icon: Icon(Icons.person, size: 20),
                        ),
                        Tab(
                          text: 'Portfolio',
                          icon: Icon(Icons.work, size: 20),
                        ),
                      ],
                    )
                  : null,
            )
          : null,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(authService),
        ),
      ),
      floatingActionButton: isFundi ? _buildFloatingActionButton() : null,
    );
  }

  /// Build floating action button for adding portfolio items
  Widget? _buildFloatingActionButton() {
    // Only show FAB on portfolio tab
    if (_tabController.index == 1) {
      return FloatingActionButton.extended(
        onPressed: _navigateToCreatePortfolio,
        icon: const Icon(Icons.add),
        label: const Text('Add Work'),
        backgroundColor: context.primaryColor,
      );
    }
    return null;
  }

  /// Navigate to portfolio creation screen
  Future<void> _navigateToCreatePortfolio() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PortfolioCreationScreen()),
    );

    if (result == true && mounted) {
      // Reload portfolio after creation
      _loadPortfolio();
    }
  }

  Widget _buildBody(AuthService authService) {
    if (_isLoading) {
      // Shimmer profile header while loading
      return const Padding(
        padding: EdgeInsets.all(16),
        child: ShimmerUserProfile(),
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
                if (mounted) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Retry',
              onPressed: _loadProfile,
              type: ButtonType.secondary,
            ),
          ],
        ),
      );
    }

    if (_profile == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Profile not found'),
            SizedBox(height: 8),
            Text('Unable to load your profile information'),
          ],
        ),
      );
    }

    // Use tabs for fundi users
    if (_profile!.isFundi) {
      return TabBarView(
        controller: _tabController,
        children: [_buildProfileTab(authService), _buildPortfolioTab()],
      );
    }

    // Regular profile view for non-fundi users
    return _buildProfileTab(authService);
  }

  /// Build profile information tab
  Widget _buildProfileTab(AuthService authService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(),

          const SizedBox(height: 32),

          // Basic Information
          _buildSection(
            title: 'Basic Information',
            children: [
              _buildInfoRow('Name', _profile!.fullName),
              _buildInfoRow('Email', _profile!.email),
              _buildInfoRow('Phone', _profile!.phoneNumber ?? 'Not provided'),
              _buildInfoRow('Role', _profile!.role.displayName),
              _buildInfoRow('Status', _profile!.status.displayName),
            ],
          ),

          const SizedBox(height: 24),

          // Professional Information
          if (_profile!.isFundi) ...[
            _buildSection(
              title: 'Professional Information',
              children: [
                if (_profile!.bio != null) _buildInfoRow('Bio', _profile!.bio!),
                if (_profile!.location != null)
                  _buildInfoRow('Location', _profile!.location!),
                if (_profile!.nidaNumber != null)
                  _buildInfoRow('NIDA Number', _profile!.nidaNumber!),
                if (_profile!.vetaCertificate != null)
                  _buildInfoRow('VETA Certificate', _profile!.vetaCertificate!),
                _buildInfoRow('Rating', _profile!.ratingDisplay),
                _buildInfoRow('Total Jobs', _profile!.totalJobs.toString()),
                _buildInfoRow(
                  'Completed Jobs',
                  _profile!.completedJobs.toString(),
                ),
                _buildInfoRow(
                  'Completion Rate',
                  '${_profile!.completionRate.toStringAsFixed(1)}%',
                ),
                _buildInfoRow('Total Earnings', _profile!.earningsDisplay),
              ],
            ),

            const SizedBox(height: 24),
          ],

          // Skills
          if (_profile!.skills.isNotEmpty) ...[
            _buildSection(
              title: 'Skills',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _profile!.skills
                      .map(
                        (skill) => Chip(
                          label: Text(skill),
                          backgroundColor: context.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          labelStyle: TextStyle(color: context.primaryColor),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],

          // Languages
          if (_profile!.languages.isNotEmpty) ...[
            _buildSection(
              title: 'Languages',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _profile!.languages
                      .map(
                        (language) => Chip(
                          label: Text(language),
                          backgroundColor: AppTheme.lightGray,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],

          // Action Buttons
          Column(
            children: [
              // Edit Profile Button
              AppButton(
                text: 'Edit Profile',
                onPressed: _editProfile,
                isFullWidth: true,
                size: ButtonSize.large,
                icon: Icons.edit,
              ),

              const SizedBox(height: 16),

              // Become Fundi Button (only for customers)
              if (authService.currentUser?.isCustomer ?? false) ...[
                AppButton(
                  text: 'Become a Fundi',
                  onPressed: _navigateToFundiApplication,
                  isFullWidth: true,
                  size: ButtonSize.large,
                  type: ButtonType.secondary,
                  icon: Icons.build_circle,
                ),
                const SizedBox(height: 16),
              ],

              // Fundi Application Status (for customers who applied)
              if (authService.currentUser?.isCustomer ?? false) ...[
                _buildFundiApplicationStatus(),
                const SizedBox(height: 16),
              ],
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Build portfolio tab for fundi users
  Widget _buildPortfolioTab() {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolioProvider, child) {
        if (portfolioProvider.isLoading) {
          return const Center(child: LoadingWidget());
        }

        if (portfolioProvider.errorMessage != null) {
          return Center(
            child: AppErrorWidget(
              message: portfolioProvider.errorMessage!,
              onRetry: _loadPortfolio,
            ),
          );
        }

        final portfolios = portfolioProvider.portfolios;

        if (portfolios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_outline, size: 64, color: AppTheme.mediumGray),
                const SizedBox(height: 16),
                Text(
                  'No Portfolio Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mediumGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start building your portfolio by adding your best work',
                  style: TextStyle(color: AppTheme.mediumGray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Add Your First Work',
                  onPressed: _navigateToCreatePortfolio,
                  icon: Icons.add,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadPortfolio,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: portfolios.length,
            itemBuilder: (context, index) {
              return _buildPortfolioCard(portfolios[index]);
            },
          ),
        );
      },
    );
  }

  /// Build portfolio card widget
  Widget _buildPortfolioCard(PortfolioModel portfolio) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PortfolioDetailsScreen(portfolio: portfolio),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: portfolio.images.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(portfolio.images.first),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: portfolio.images.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: AppTheme.mediumGray,
                        ),
                      )
                    : null,
              ),
            ),
            // Portfolio Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      portfolio.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      portfolio.description,
                      style: TextStyle(
                        color: AppTheme.mediumGray,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        if (portfolio.images.length > 1)
                          Row(
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 14,
                                color: AppTheme.mediumGray,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${portfolio.images.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.mediumGray,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primaryColor,
            context.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: _profile!.profileImageUrl != null
                ? NetworkImage(_profile!.profileImageUrl!)
                : null,
            child: _profile!.profileImageUrl == null
                ? Text(
                    _profile!.initials,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  )
                : null,
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            _profile!.fullName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Role and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _profile!.role.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _profile!.isVerified
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _profile!.verificationStatusText,
                  style: TextStyle(
                    color: _profile!.isVerified ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Online Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _profile!.isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _profile!.isOnline ? 'Online' : _profile!.onlineStatusText,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.darkGray),
            ),
          ),
        ],
      ),
    );
  }
}
