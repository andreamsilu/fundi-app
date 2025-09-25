import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button_widget.dart';

/// Help and Support screen
/// Provides contact information, FAQ, and support options
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),

              const SizedBox(height: 32),

              // Contact Section
              _buildSection(
                title: 'Contact Us',
                children: [
                  _buildContactItem(
                    icon: Icons.phone,
                    title: 'Phone Support',
                    subtitle: '+255 123 456 789',
                    onTap: () => _launchPhone('0754289824'),
                  ),
                  _buildContactItem(
                    icon: Icons.email,
                    title: 'Email Support',
                    subtitle: 'support@fundi.co.tz',
                    onTap: () => _launchEmail('support@fundi.co.tz'),
                  ),
                  _buildContactItem(
                    icon: Icons.chat,
                    title: 'Live Chat',
                    subtitle: 'Available 24/7',
                    onTap: () => _showLiveChatDialog(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // FAQ Section
              _buildSection(
                title: 'Frequently Asked Questions',
                children: [
                  _buildFAQItem(
                    question: 'How do I post a job?',
                    answer:
                        'Tap the + button on the home screen, fill in the job details, and submit. Your job will be visible to fundis in your area.',
                  ),
                  _buildFAQItem(
                    question: 'How do I apply for a job?',
                    answer:
                        'Browse available jobs, tap on a job you\'re interested in, and click "Apply". Fill in your proposal and submit.',
                  ),
                  _buildFAQItem(
                    question: 'How do I get paid?',
                    answer:
                        'Payment is processed through the app after job completion. You can withdraw funds to your bank account or mobile money.',
                  ),
                  _buildFAQItem(
                    question: 'How do I rate a fundi?',
                    answer:
                        'After job completion, you\'ll receive a notification to rate the fundi. You can also rate from the job details screen.',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // App Info Section
              _buildSection(
                title: 'App Information',
                children: [
                  _buildInfoItem('Version', '1.0.0'),
                  _buildInfoItem('Last Updated', 'December 2024'),
                  _buildInfoItem('Platform', 'Flutter'),
                ],
              ),

              const SizedBox(height: 32),

              // Support Actions
              _buildSupportActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentGreen,
            AppTheme.accentGreen.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.help_outline, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'How can we help you?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re here to help you get the most out of Fundi',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
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
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.accentGreen.withValues(alpha: 0.1),
        child: Icon(icon, color: AppTheme.accentGreen),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: TextStyle(color: AppTheme.mediumGray)),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: AppTheme.mediumGray)),
        ],
      ),
    );
  }

  Widget _buildSupportActions() {
    return Column(
      children: [
        AppButton(
          text: 'Send Feedback',
          onPressed: () => _launchEmail('feedback@fundi.co.tz'),
          type: ButtonType.primary,
        ),
        const SizedBox(height: 12),
        AppButton(
          text: 'Report a Bug',
          onPressed: () => _launchEmail('bugs@fundi.co.tz'),
          type: ButtonType.secondary,
        ),
      ],
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showSnackBar('Could not launch phone app');
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Fundi App Support',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showSnackBar('Could not launch email app');
    }
  }

  void _showLiveChatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Live Chat'),
          content: const Text(
            'Live chat is currently being developed. Please use phone or email support for now.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
