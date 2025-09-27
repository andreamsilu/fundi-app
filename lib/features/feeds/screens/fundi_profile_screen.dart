import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fundi/shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../services/feeds_service.dart';
import '../widgets/portfolio_item_card.dart';
import '../widgets/request_fundi_dialog.dart';

class FundiProfileScreen extends StatefulWidget {
  final dynamic fundi;

  const FundiProfileScreen({Key? key, required this.fundi}) : super(key: key);

  @override
  State<FundiProfileScreen> createState() => _FundiProfileScreenState();
}

class _FundiProfileScreenState extends State<FundiProfileScreen> {
  final FeedsService _feedsService = FeedsService();
  dynamic _fundiDetails;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fundiDetails = widget.fundi;
    _loadFundiDetails();
  }

  Future<void> _loadFundiDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Safely get fundi ID
      final fundiId = widget.fundi?['id']?.toString();
      if (fundiId == null || fundiId.isEmpty) {
        if (!mounted) return;
        setState(() {
          _error = 'Invalid fundi ID';
        });
        return;
      }

      final result = await _feedsService.getFundiProfile(fundiId);

      if (result['success'] && result['fundi'] != null) {
        if (!mounted) return;
        setState(() {
          _fundiDetails = result['fundi'];
        });
      } else {
        if (!mounted) return;
        setState(() {
          _error = result['message'] ?? 'Failed to load fundi details';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load fundi details: ${e.toString()}';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => RequestFundiDialog(
        fundi: _fundiDetails ?? widget.fundi,
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
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Try to check if user is customer, but don't block if provider not available
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isCustomer) {
        return const Center(
          child: Text('Only customers can view fundi profiles'),
        );
      }
    } catch (e) {
      // Provider not available, continue anyway
      print('AuthProvider not available in FundiProfileScreen: $e');
    }

    if (_isLoading && _fundiDetails == null) {
      return const LoadingWidget();
    }

    if (_error != null && _fundiDetails == null) {
      return AppErrorWidget(message: _error!, onRetry: _loadFundiDetails);
    }

    final fundi = _fundiDetails ?? widget.fundi;
    if (fundi == null) {
      return const Center(child: Text('Fundi data not available'));
    }

    final portfolioItems =
        fundi['portfolio_items'] as List<dynamic>? ??
        fundi['visible_portfolio'] as List<dynamic>? ??
        [];
    final averageRating =
        fundi['average_rating']?.toDouble() ??
        fundi['rating']?.toDouble() ??
        0.0;
    final totalRatings = fundi['total_ratings'] ?? 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    (fundi['name']?.toString() ??
                            fundi['full_name']?.toString() ??
                            'Unknown')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  fundi['name']?.toString() ??
                      fundi['full_name']?.toString() ??
                      'Unknown Fundi',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '($totalRatings reviews)',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Contact & Location Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fundi['email'] != null) ...[
                  _buildInfoRow(Icons.email, 'Email', fundi['email']),
                  const SizedBox(height: 8),
                ],
                if (fundi['phone'] != null) ...[
                  _buildInfoRow(Icons.phone, 'Phone', fundi['phone']),
                  const SizedBox(height: 8),
                ],
                if (fundi['fundi_profile'] != null &&
                    fundi['fundi_profile']['location'] != null) ...[
                  _buildInfoRow(
                    Icons.location_on,
                    'Location',
                    fundi['fundi_profile']['location'],
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),

          // Skills Section
          Builder(
            builder: (context) {
              List<String> skills = [];

              // Try to get skills from fundi_profile
              if (fundi['fundi_profile'] != null &&
                  fundi['fundi_profile']['skills'] != null) {
                final skillsData = fundi['fundi_profile']['skills'];
                if (skillsData is String) {
                  try {
                    final decoded = jsonDecode(skillsData) as List<dynamic>;
                    skills = List<String>.from(decoded);
                  } catch (e) {
                    skills = skillsData
                        .split(',')
                        .map((s) => s.trim())
                        .toList();
                  }
                } else if (skillsData is List) {
                  skills = List<String>.from(skillsData);
                }
              }

              // Try to get skills from direct fundi data
              if (skills.isEmpty && fundi['skills'] != null) {
                if (fundi['skills'] is List) {
                  skills = List<String>.from(fundi['skills']);
                }
              }

              if (skills.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Skills',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills
                          .map<Widget>(
                            (skill) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                skill.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),

          // Portfolio Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Portfolio',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (portfolioItems.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No portfolio items yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: portfolioItems.length,
                    itemBuilder: (context, index) {
                      return PortfolioItemCard(
                        portfolioItem: portfolioItems[index],
                      );
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Request Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showRequestDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Request This Fundi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }
}
