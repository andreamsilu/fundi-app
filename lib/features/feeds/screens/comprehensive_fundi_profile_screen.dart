import 'package:flutter/material.dart';
import 'package:fundi/shared/widgets/loading_widget.dart';
import 'package:fundi/shared/widgets/error_widget.dart';
import '../models/comprehensive_fundi_profile.dart';
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
      final fundiId = widget.fundi?['id']?.toString();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fundi Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
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

          const SizedBox(height: 20),
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
                ? Text(
                    _fundiProfile!.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),

          const SizedBox(height: 16),

          // Name and Verification Status
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
        if (_fundiProfile!.bio != null && _fundiProfile!.bio!.isNotEmpty)
          _buildDetailRow(Icons.info, 'Bio', _fundiProfile!.bio!),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return _buildSection(
      title: 'Skills & Experience',
      icon: Icons.work,
      children: [
        if (_fundiProfile!.skills.isNotEmpty) ...[
          const Text('Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fundiProfile!.skills
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (_fundiProfile!.experienceYears != null)
          _buildDetailRow(
            Icons.timeline,
            'Experience',
            _fundiProfile!.experienceDisplay,
          ),
        if (_fundiProfile!.primaryCategory != null)
          _buildDetailRow(
            Icons.category,
            'Primary Category',
            _fundiProfile!.primaryCategory!,
          ),
      ],
    );
  }

  Widget _buildCertificationsSection() {
    return _buildSection(
      title: 'Certifications',
      icon: Icons.school,
      children: [
        if (_fundiProfile!.hasVetaCertificate)
          _buildDetailRow(Icons.verified, 'VETA Certificate', 'Certified'),
        if (_fundiProfile!.otherCertifications.isNotEmpty) ...[
          const Text(
            'Other Certifications:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._fundiProfile!.otherCertifications.map(
            (cert) => _buildDetailRow(Icons.card_membership, cert, ''),
          ),
        ],
        if (!_fundiProfile!.hasVetaCertificate &&
            _fundiProfile!.otherCertifications.isEmpty)
          const Text('No certifications available'),
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
    return _buildSection(
      title: 'Recent Works',
      icon: Icons.photo_library,
      children: [
        if (_fundiProfile!.recentWorks.isNotEmpty) ...[
          Text('${_fundiProfile!.recentWorks.length} recent works'),
          const SizedBox(height: 16),
          ..._fundiProfile!.recentWorks
              .take(3)
              .map((work) => PortfolioItemCard(portfolioItem: work.toJson())),
          if (_fundiProfile!.recentWorks.length > 3)
            TextButton(
              onPressed: () {
                // TODO: Navigate to full portfolio
              },
              child: Text(
                'View all ${_fundiProfile!.totalPortfolioItems} works',
              ),
            ),
        ] else
          const Text('No recent works available'),
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
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _fundiProfile!.isAvailable ? _showRequestDialog : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
