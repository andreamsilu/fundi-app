import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/work_approval_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize work approval data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WorkApprovalProvider>().initialize();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await context.read<WorkApprovalProvider>().refreshAll();
  }

  Future<void> _approvePortfolioItem(String itemId) async {
    final result = await context
        .read<WorkApprovalProvider>()
        .approvePortfolioItem(itemId: itemId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectPortfolioItem(String itemId, String reason) async {
    final result = await context
        .read<WorkApprovalProvider>()
        .rejectPortfolioItem(itemId: itemId, rejectionReason: reason);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.orange : Colors.red,
        ),
      );
    }
  }

  Future<void> _approveWorkSubmission(String submissionId) async {
    final result = await context
        .read<WorkApprovalProvider>()
        .approveWorkSubmission(submissionId: submissionId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectWorkSubmission(String submissionId, String reason) async {
    final result = await context
        .read<WorkApprovalProvider>()
        .rejectWorkSubmission(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, WorkApprovalProvider>(
      builder: (context, authProvider, workApprovalProvider, child) {
        if (!authProvider.isCustomer) {
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
              _buildPortfolioItemsTab(workApprovalProvider),
              // Work Submissions Tab
              _buildWorkSubmissionsTab(workApprovalProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPortfolioItemsTab(WorkApprovalProvider provider) {
    if (provider.isLoadingPortfolioItems &&
        provider.pendingPortfolioItems.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    if (provider.portfolioItemsError != null &&
        provider.pendingPortfolioItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.portfolioItemsError!,
              style: const TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: () =>
                  provider.loadPendingPortfolioItems(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.pendingPortfolioItems.isEmpty) {
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
        itemCount:
            provider.pendingPortfolioItems.length +
            (provider.isLoadingMorePortfolioItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.pendingPortfolioItems.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final item = provider.pendingPortfolioItems[index];
          return PortfolioApprovalCard(
            portfolioItem: item.toJson(),
            onApprove: () => _approvePortfolioItem(item.id),
            onReject: (reason) => _rejectPortfolioItem(item.id, reason),
          );
        },
      ),
    );
  }

  Widget _buildWorkSubmissionsTab(WorkApprovalProvider provider) {
    if (provider.isLoadingWorkSubmissions &&
        provider.pendingWorkSubmissions.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    if (provider.workSubmissionsError != null &&
        provider.pendingWorkSubmissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.workSubmissionsError!,
              style: const TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: () =>
                  provider.loadPendingWorkSubmissions(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.pendingWorkSubmissions.isEmpty) {
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
        itemCount:
            provider.pendingWorkSubmissions.length +
            (provider.isLoadingMoreWorkSubmissions ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.pendingWorkSubmissions.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final submission = provider.pendingWorkSubmissions[index];
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
