import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import 'profile_edit_screen.dart';
import '../../fundi_application/screens/fundi_application_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../portfolio/providers/portfolio_provider.dart';
import '../../portfolio/models/portfolio_model.dart';
import '../../portfolio/screens/portfolio_details_screen.dart';
import '../../portfolio/screens/portfolio_creation_screen.dart';

/// Modern Profile Screen with Enhanced UI/UX
/// Features: Gradient headers, card-based layout, statistics, smooth animations
class ProfileScreenModern extends StatefulWidget {
  final String? userId;
  final bool showAppBar;

  const ProfileScreenModern({super.key, this.userId, this.showAppBar = true});

  @override
  State<ProfileScreenModern> createState() => _ProfileScreenModernState();
}

class _ProfileScreenModernState extends State<ProfileScreenModern>
    with TickerProviderStateMixin {
  ProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _setupAnimations();
    _loadProfile();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final profile = await ProfileService().getProfile(widget.userId ?? '');

      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }

      if (_profile?.isFundi ?? false) {
        _loadPortfolio();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPortfolio() async {
    if (!mounted) return;
    final portfolioProvider = Provider.of<PortfolioProvider>(
      context,
      listen: false,
    );
    await portfolioProvider.loadPortfolios();
  }

  Future<void> _editProfile() async {
    if (_profile == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(profile: _profile!),
      ),
    );

    if (result != null && result is ProfileModel) {
      setState(() => _profile = result);
    }
  }

  void _navigateToFundiApplication() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FundiApplicationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFundi = _profile?.isFundi ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              iconTheme: IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  onPressed: _editProfile,
                  icon: Icon(Icons.edit_outlined, color: Colors.white),
                  tooltip: 'Edit Profile',
                ),
                SizedBox(width: 8),
              ],
            )
          : null,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(scale: _scaleAnimation, child: _buildBody()),
      ),
      floatingActionButton: isFundi && _tabController.index == 1
          ? _buildModernFAB()
          : null,
    );
  }

  Widget _buildModernFAB() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCreatePortfolio,
      icon: Icon(Icons.add_photo_alternate_outlined),
      label: Text('Add Work', style: TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: AppTheme.primaryGreen,
      elevation: 4,
    );
  }

  Future<void> _navigateToCreatePortfolio() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PortfolioCreationScreen()),
    );
    if (result == true && mounted) _loadPortfolio();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_profile == null) {
      return _buildEmptyState();
    }

    return Stack(
      children: [
        // Gradient Header Background
        _buildGradientHeader(),

        // Content
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: widget.showAppBar ? 100 : 60),
            ),

            // Profile Card
            SliverToBoxAdapter(child: _buildProfileCard()),

            // Tabs or Direct Content
            if (_profile!.isFundi) ...[
              SliverToBoxAdapter(child: _buildModernTabs()),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildProfileContent(), _buildPortfolioContent()],
                ),
              ),
            ] else
              SliverToBoxAdapter(child: _buildProfileContent()),
          ],
        ),
      ],
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withOpacity(0.8),
            Colors.teal.shade400,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Transform.translate(
      offset: Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                Hero(
                  tag: 'profile_avatar_${_profile!.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryGreen,
                      child: Text(
                        _profile!.initials,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Name
                Text(
                  _profile!.fullName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 4),

                // Role Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: _profile!.isFundi
                        ? AppTheme.primaryGreen.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _profile!.isFundi ? Icons.build_circle : Icons.person,
                        size: 16,
                        color: _profile!.isFundi
                            ? AppTheme.primaryGreen
                            : Colors.blue,
                      ),
                      SizedBox(width: 6),
                      Text(
                        _profile!.role.displayName,
                        style: TextStyle(
                          color: _profile!.isFundi
                              ? AppTheme.primaryGreen
                              : Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Fundi Stats
                if (_profile!.isFundi) ...[
                  SizedBox(height: 20),
                  _buildStatsRow(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          icon: Icons.star_rounded,
          value: _profile!.ratingDisplay,
          label: 'Rating',
          color: Colors.amber,
        ),
        _buildDivider(),
        _buildStatItem(
          icon: Icons.work_rounded,
          value: _profile!.totalJobs.toString(),
          label: 'Jobs',
          color: Colors.blue,
        ),
        _buildDivider(),
        _buildStatItem(
          icon: Icons.check_circle_rounded,
          value: '${_profile!.completionRate.toInt()}%',
          label: 'Success',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGray,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.mediumGray)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: AppTheme.lightGray);
  }

  Widget _buildModernTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.mediumGray,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'Profile', icon: Icon(Icons.person_outline, size: 18)),
          Tab(text: 'Portfolio', icon: Icon(Icons.work_outline, size: 18)),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Information Card
          _buildModernCard(
            title: 'Contact Information',
            icon: Icons.contact_phone_rounded,
            children: [
              _buildModernInfoTile(
                Icons.phone_rounded,
                'Phone',
                _profile!.phoneNumber ?? 'Not provided',
              ),
              _buildModernInfoTile(
                Icons.email_rounded,
                'Email',
                _profile!.email,
              ),
              if (_profile!.location != null)
                _buildModernInfoTile(
                  Icons.location_on_rounded,
                  'Location',
                  _profile!.location!,
                ),
            ],
          ),

          SizedBox(height: 16),

          // Professional Info (Fundis only)
          if (_profile!.isFundi) ...[
            _buildModernCard(
              title: 'Professional Details',
              icon: Icons.business_center_rounded,
              children: [
                if (_profile!.bio != null) _buildBioSection(_profile!.bio!),
                if (_profile!.nidaNumber != null)
                  _buildModernInfoTile(
                    Icons.badge_rounded,
                    'NIDA',
                    _profile!.nidaNumber!,
                  ),
                if (_profile!.vetaCertificate != null)
                  _buildModernInfoTile(
                    Icons.verified_rounded,
                    'VETA',
                    _profile!.vetaCertificate!,
                  ),
                _buildModernInfoTile(
                  Icons.attach_money_rounded,
                  'Earnings',
                  _profile!.earningsDisplay,
                ),
              ],
            ),
            SizedBox(height: 16),
          ],

          // Skills Card
          if (_profile!.skills.isNotEmpty) ...[
            _buildModernCard(
              title: 'Skills',
              icon: Icons.psychology_rounded,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _profile!.skills
                      .map((skill) => _buildSkillChip(skill))
                      .toList(),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],

          // Languages Card
          if (_profile!.languages.isNotEmpty) ...[
            _buildModernCard(
              title: 'Languages',
              icon: Icons.language_rounded,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _profile!.languages
                      .map((lang) => _buildLanguageChip(lang))
                      .toList(),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],

          // Action Buttons
          _buildActionButtons(),

          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppTheme.mediumGray),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(String bio) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        bio,
        style: TextStyle(fontSize: 14, color: AppTheme.darkGray, height: 1.5),
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.1),
            AppTheme.primaryGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: AppTheme.primaryGreen,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String language) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.translate, size: 14, color: Colors.blue),
          SizedBox(width: 6),
          Text(
            language,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final authService = AuthService();

    return Column(
      children: [
        // Edit Profile
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryGreen, Colors.teal.shade400],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _editProfile,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Become a Fundi
        if (authService.currentUser?.isCustomer ?? false) ...[
          SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _navigateToFundiApplication,
            icon: Icon(Icons.build_circle_rounded),
            label: Text('Become a Fundi'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              side: BorderSide(color: AppTheme.primaryGreen, width: 2),
              foregroundColor: AppTheme.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPortfolioContent() {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolioProvider, child) {
        if (portfolioProvider.isLoading) {
          return Center(child: LoadingWidget());
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
          return _buildEmptyPortfolio();
        }

        return GridView.builder(
          padding: EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: portfolios.length,
          itemBuilder: (context, index) {
            return _buildModernPortfolioCard(portfolios[index]);
          },
        );
      },
    );
  }

  Widget _buildModernPortfolioCard(PortfolioModel portfolio) {
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
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                color: AppTheme.lightGray,
                child: (portfolio.imageUrls?.isNotEmpty ?? false)
                    ? Image.network(
                        portfolio.imageUrls!.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Center(
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: AppTheme.mediumGray,
                        ),
                      ),
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    portfolio.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 12,
                        color: AppTheme.mediumGray,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          portfolio.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.mediumGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPortfolio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline_rounded,
              size: 64,
              color: AppTheme.mediumGray,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Portfolio Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start building your portfolio\nto showcase your work',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mediumGray),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreatePortfolio,
            icon: Icon(Icons.add_photo_alternate_outlined),
            label: Text('Add Your First Work'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Center(child: LoadingWidget(message: 'Loading profile...'));
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Failed to load profile',
            style: TextStyle(color: AppTheme.mediumGray),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadProfile,
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 64, color: AppTheme.mediumGray),
          SizedBox(height: 16),
          Text(
            'Profile Not Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Shimmer Loading Widget
class ShimmerUserProfile extends StatelessWidget {
  const ShimmerUserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Shimmer avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: 16),
        // Shimmer text lines
        Container(width: 200, height: 20, color: AppTheme.lightGray),
        SizedBox(height: 8),
        Container(width: 150, height: 16, color: AppTheme.lightGray),
      ],
    );
  }
}
