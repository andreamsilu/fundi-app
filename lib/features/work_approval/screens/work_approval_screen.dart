import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../services/work_approval_service.dart';
import '../models/work_submission_model.dart';
import '../widgets/portfolio_approval_card.dart';
import '../widgets/work_submission_card.dart';
import '../../../shared/widgets/loading_widget.dart';

class WorkApprovalScreen extends StatefulWidget {
  const WorkApprovalScreen({Key? key}) : super(key: key);

  @override
  State<WorkApprovalScreen> createState() => _WorkApprovalScreenState();
}

class _WorkApprovalScreenState extends State<WorkApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WorkApprovalService _workApprovalService = WorkApprovalService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  List<dynamic> _pendingPortfolioItems = [];
  List<WorkSubmissionModel> _pendingWorkSubmissions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final portfolioResult = await _workApprovalService
          .getPendingPortfolioItems();
      final submissionsResult = await _workApprovalService
          .getPendingWorkSubmissions();

      if (mounted) {
        setState(() {
          _pendingPortfolioItems = portfolioResult['portfolioItems'] ?? [];
          _pendingWorkSubmissions = submissionsResult['workSubmissions'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Future<void> _approvePortfolioItem(String itemId) async {
    final result = await _workApprovalService.approvePortfolioItem(
      itemId: itemId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      if (result['success']) {
        await _loadData();
      }
    }
  }

  Future<void> _rejectPortfolioItem(String itemId, String reason) async {
    final result = await _workApprovalService.rejectPortfolioItem(
      itemId: itemId,
      rejectionReason: reason,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.orange : Colors.red,
        ),
      );
      if (result['success']) {
        await _loadData();
      }
    }
  }

  Future<void> _approveWorkSubmission(String submissionId) async {
    final result = await _workApprovalService.approveWorkSubmission(
      submissionId: submissionId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      if (result['success']) {
        await _loadData();
      }
    }
  }

  Future<void> _rejectWorkSubmission(String submissionId, String reason) async {
    final result = await _workApprovalService.rejectWorkSubmission(
      submissionId: submissionId,
      rejectionReason: reason,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.orange : Colors.red,
        ),
      );
      if (result['success']) {
        await _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(_authService.currentUser?.isCustomer ?? false)) {
      return const Scaffold(
        body: Center(child: Text('Only customers can approve work')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Approval'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Portfolio Items', icon: Icon(Icons.work_outline)),
            Tab(
              text: 'Work Submissions',
              icon: Icon(Icons.assignment_turned_in),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Portfolio Items Tab
          _buildPortfolioItemsTab(),
          // Work Submissions Tab
          _buildWorkSubmissionsTab(),
        ],
      ),
    );
  }

  Widget _buildPortfolioItemsTab() {
    if (_isLoading && _pendingPortfolioItems.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    if (_pendingPortfolioItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No pending portfolio items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'All portfolio items have been reviewed',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingPortfolioItems.length,
        itemBuilder: (context, index) {
          final item = _pendingPortfolioItems[index];
          return PortfolioApprovalCard(
            portfolioItem: item,
            onApprove: () => _approvePortfolioItem(item['id'].toString()),
            onReject: (reason) =>
                _rejectPortfolioItem(item['id'].toString(), reason),
          );
        },
      ),
    );
  }

  Widget _buildWorkSubmissionsTab() {
    if (_isLoading && _pendingWorkSubmissions.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    if (_pendingWorkSubmissions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No pending work submissions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'All work submissions have been reviewed',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingWorkSubmissions.length,
        itemBuilder: (context, index) {
          final submission = _pendingWorkSubmissions[index];
          return WorkSubmissionCard(
            workSubmission: submission.toJson(),
            onApprove: () => _approveWorkSubmission(submission.id),
            onReject: (reason) => _rejectWorkSubmission(submission.id, reason),
          );
        },
      ),
    );
  }
}
