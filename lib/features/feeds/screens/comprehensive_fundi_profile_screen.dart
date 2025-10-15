import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fundi/shared/widgets/loading_widget.dart';
import 'package:fundi/shared/widgets/error_widget.dart';
import '../models/comprehensive_fundi_profile.dart';
import '../models/fundi_model.dart';
import '../services/feeds_service.dart';
import '../widgets/portfolio_item_card.dart';
import '../widgets/request_fundi_dialog.dart';
import '../widgets/rating_summary_widget.dart';
import '../widgets/availability_status_widget.dart';

/// Comprehensive fundi profile screen showing all required details
class ComprehensiveFundiProfileScreen extends StatefulWidget {
  final dynamic fundi;

  const ComprehensiveFundiProfileScreen({Key? key, required this.fundi})
    : super(key: key);

  @override
  State<ComprehensiveFundiProfileScreen> createState() =>
      _ComprehensiveFundiProfileScreenState();
}

class _ComprehensiveFundiProfileScreenState
    extends State<ComprehensiveFundiProfileScreen> {
  final FeedsService _feedsService = FeedsService();
  ComprehensiveFundiProfile? _fundiProfile;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFundiProfile();
  }

  Future<void> _loadFundiProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Handle both Map and FundiModel
      String? fundiId;
      if (widget.fundi is Map) {
        fundiId = widget.fundi?['id']?.toString();
      } else if (widget.fundi is FundiModel) {
        fundiId = (widget.fundi as FundiModel).id;
      } else {
        fundiId = widget.fundi?.id?.toString();
      }

      if (fundiId == null || fundiId.isEmpty) {
        setState(() {
          _error = 'Invalid fundi ID';
        });
        return;
      }

      final result = await _feedsService.getFundiProfile(fundiId);

      if (result['success'] == true && result['fundi'] != null) {
        setState(() {
          _fundiProfile = ComprehensiveFundiProfile.fromJson(result['fundi']);
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load fundi profile';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load fundi profile: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => RequestFundiDialog(
        fundi: _fundiProfile ?? widget.fundi,
        onRequestSent: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  /// Share fundi profile details
  void _shareFundiProfile() {
    if (_fundiProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile not loaded yet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Build share message
    final String shareMessage =
        '''
🔨 ${_fundiProfile!.fullName}
${_fundiProfile!.primaryCategory ?? 'Skilled Fundi'}

⭐ Rating: ${_fundiProfile!.formattedAverageRating}/5.0 (${_fundiProfile!.totalRatings} reviews)
💼 Completed Jobs: ${_fundiProfile!.totalPortfolioItems}
📍 Location: ${_fundiProfile!.locationString}

${_fundiProfile!.bio ?? 'Experienced professional ready to help!'}

Find skilled fundis on Fundi App!
''';

    Share.share(
      shareMessage,
      subject: 'Check out ${_fundiProfile!.fullName} on Fundi App',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fundi Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareFundiProfile,
            tooltip: 'Share Profile',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_error != null) {
      return Center(
        child: AppErrorWidget(message: _error!, onRetry: _loadFundiProfile),
      );
    }

    if (_fundiProfile == null) {
      return const Center(child: Text('Fundi profile not available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Profile Image and Basic Info
          _buildHeaderSection(),

          // Personal Details Section
          _buildPersonalDetailsSection(),

          // Statistics Section
          _buildStatisticsSection(),

          // Fundi Category & Skills Section
          _buildSkillsSection(),

          // Certifications Section
          _buildCertificationsSection(),

          // Availability Status Section
          _buildAvailabilitySection(),

          // Recent Works (Portfolio) Section
          _buildRecentWorksSection(),

          // Reviews & Ratings Section
          _buildReviewsSection(),

          // Request Button
          _buildRequestButton(),

          // Bottom margin to ensure button is fully visible
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: _fundiProfile!.profileImage != null
                ? NetworkImage(_fundiProfile!.profileImage!)
                : null,
            child: _fundiProfile!.profileImage == null
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Text(
                        _fundiProfile!.fullName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  )
                : null,
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            _fundiProfile!.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Profession/Primary Category
          if (_fundiProfile!.primaryCategory != null)
            Text(
              _fundiProfile!.primaryCategory!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 12),

          // Verification Badge
          if (_fundiProfile!.isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Verified ✓',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Rating and Reviews
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                _fundiProfile!.formattedAverageRating,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_fundiProfile!.totalRatings} reviews)',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsSection() {
    return _buildSection(
      title: 'Personal Details',
      icon: Icons.person,
      children: [
        _buildDetailRow(Icons.phone, 'Phone', _fundiProfile!.phone),
        _buildDetailRow(Icons.email, 'Email', _fundiProfile!.email),
        _buildDetailRow(
          Icons.location_on,
          'Location',
          _fundiProfile!.locationString,
        ),
        if (_fundiProfile!.createdAt != null)
          _buildDetailRow(
            Icons.calendar_today,
            'Member Since',
            _formatMemberSince(_fundiProfile!.createdAt!),
          ),
        if (_fundiProfile!.bio != null && _fundiProfile!.bio!.isNotEmpty)
          _buildDetailRow(Icons.info, 'Bio', _fundiProfile!.bio!),
      ],
    );
  }

  /// Build statistics section showing job stats and hourly rate
  Widget _buildStatisticsSection() {
    // Get metadata for total and completed jobs
    final totalJobs = _fundiProfile!.metadata?['totalJobs'] ?? 0;
    final completedJobs = _fundiProfile!.metadata?['completedJobs'] ?? 0;
    final hourlyRate = _fundiProfile!.metadata?['hourlyRate'] ?? 0.0;

    return _buildSection(
      title: 'Statistics',
      icon: Icons.bar_chart,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.work_outline,
                label: 'Total Jobs',
                value: totalJobs.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle_outline,
                label: 'Completed',
                value: completedJobs.toString(),
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.photo_library_outlined,
                label: 'Portfolio Items',
                value: _fundiProfile!.totalPortfolioItems.toString(),
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.payments_outlined,
                label: 'Hourly Rate',
                value: hourlyRate > 0
                    ? '${hourlyRate.toStringAsFixed(0)}/hr'
                    : 'Not Set',
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build a stat card widget
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Format member since date
  String _formatMemberSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      if (weeks == 0) {
        return 'Joined ${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
      }
      return 'Joined $weeks week${weeks != 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Joined $months month${months != 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Joined $years year${years != 1 ? 's' : ''} ago';
    }
  }

  Widget _buildSkillsSection() {
    final hasSkills = _fundiProfile!.skills.isNotEmpty;
    final hasExperience = _fundiProfile!.experienceYears != null;

    return _buildSection(
      title: 'Skills & Experience',
      icon: Icons.work,
      children: [
        // Skills Display
        if (hasSkills) ...[
          Row(
            children: [
              Icon(Icons.build_circle, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              const Text(
                'Core Skills',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fundiProfile!.skills
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.1),
                          Theme.of(context).primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          skill,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Experience Display
        if (hasExperience) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.timeline, size: 20, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Professional Experience',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fundiProfile!.experienceDisplay,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Empty State
        if (!hasSkills && !hasExperience)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.work_outline, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No skills or experience listed',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCertificationsSection() {
    final hasVeta = _fundiProfile!.hasVetaCertificate;
    final hasOtherCerts = _fundiProfile!.otherCertifications.isNotEmpty;
    final hasCertifications = hasVeta || hasOtherCerts;

    return _buildSection(
      title: 'Certifications',
      icon: Icons.school,
      children: [
        // VETA Certificate
        if (hasVeta) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.verified, size: 20, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VETA Certified',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vocational Education and Training Authority',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Other Certifications
        if (hasOtherCerts) ...[
          Row(
            children: [
              Icon(Icons.card_membership, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              const Text(
                'Additional Certifications',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._fundiProfile!.otherCertifications.map(
            (cert) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium, size: 18, color: Colors.purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cert,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Empty State
        if (!hasCertifications)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.school_outlined, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No certifications listed',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return _buildSection(
      title: 'Availability',
      icon: Icons.schedule,
      children: [
        AvailabilityStatusWidget(
          isAvailable: _fundiProfile!.isAvailable,
          status: _fundiProfile!.availabilityStatus,
          lastActiveAt: _fundiProfile!.lastActiveAt,
        ),
      ],
    );
  }

  Widget _buildRecentWorksSection() {
    final hasWorks = _fundiProfile!.recentWorks.isNotEmpty;

    return _buildSection(
      title: 'Recent Works',
      icon: Icons.photo_library,
      children: [
        if (hasWorks) ...[
          // Works count
          Row(
            children: [
              Icon(Icons.work_history, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                '${_fundiProfile!.recentWorks.length} recent work${_fundiProfile!.recentWorks.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Portfolio items
          ..._fundiProfile!.recentWorks
              .take(3)
              .map((work) => PortfolioItemCard(portfolioItem: work.toJson())),

          // View all button
          if (_fundiProfile!.totalPortfolioItems > 3)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // TODO: Navigate to full portfolio
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Full portfolio view coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(Icons.grid_view),
                label: Text(
                  'View all ${_fundiProfile!.totalPortfolioItems} works',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ] else
          // Empty State
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 40,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'No portfolio works available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'This fundi hasn\'t added any work samples yet',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return _buildSection(
      title: 'Reviews & Ratings',
      icon: Icons.star,
      children: [
        RatingSummaryWidget(
          averageRating: _fundiProfile!.averageRating,
          totalRatings: _fundiProfile!.totalRatings,
          ratingSummary: _fundiProfile!.ratingSummary,
        ),
        if (_fundiProfile!.recentReviews.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Recent Reviews:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._fundiProfile!.recentReviews
              .take(3)
              .map((review) => _buildReviewCard(review)),
        ],
      ],
    );
  }

  Widget _buildRequestButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ElevatedButton(
        onPressed: _fundiProfile!.isAvailable ? _showRequestDialog : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Text(
          _fundiProfile!.isAvailable ? 'Request This Fundi' : 'Not Available',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (value.isNotEmpty)
                  Text(
                    value,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(dynamic review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < (review.rating ?? 0) ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                review.customerName ?? 'Anonymous',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (review.review != null && review.review.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.review),
          ],
        ],
      ),
    );
  }
}
