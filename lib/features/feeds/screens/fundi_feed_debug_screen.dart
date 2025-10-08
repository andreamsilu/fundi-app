import 'package:flutter/material.dart';
import '../services/feeds_service.dart';
import '../models/fundi_model.dart';
import '../../auth/services/auth_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';

/// Debug version of FundiFeedScreen to isolate issues
class FundiFeedDebugScreen extends StatefulWidget {
  const FundiFeedDebugScreen({Key? key}) : super(key: key);

  @override
  State<FundiFeedDebugScreen> createState() => _FundiFeedDebugScreenState();
}

class _FundiFeedDebugScreenState extends State<FundiFeedDebugScreen> {
  final FeedsService _feedsService = FeedsService();

  List<FundiModel> _fundis = [];
  bool _isLoading = false;
  String? _error;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _debugInfo = 'Initializing...';
    _loadFundis();
  }

  Future<void> _loadFundis() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _debugInfo = 'Starting to load fundis...';
    });

    try {
      // Check authentication using AuthService directly
      final authService = AuthService();
      final isAuthenticated = authService.isAuthenticated;
      setState(() {
        _debugInfo = 'Auth check: $isAuthenticated';
      });

      if (!isAuthenticated) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
          _debugInfo = 'User not authenticated, cannot load fundis';
        });
        return;
      }

      setState(() {
        _debugInfo = 'Making API call...';
      });

      final result = await _feedsService.getFundis(page: 1, limit: 10);

      setState(() {
        _debugInfo =
            'API response received. Success: ${result['success']}, Message: ${result['message']}';
      });

      if (result['success'] == true) {
        final fundisData = result['fundis'] as List<dynamic>;
        final newFundis = fundisData.map((json) {
          try {
            final jsonMap = json as Map<String, dynamic>;
            return FundiModel.fromJson(jsonMap);
          } catch (e) {
            print('Error parsing fundi: $e');
            return FundiModel.empty();
          }
        }).toList();

        setState(() {
          _fundis = newFundis;
          _isLoading = false;
          _debugInfo = 'Successfully loaded ${newFundis.length} fundis';
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Unknown error';
          _isLoading = false;
          _debugInfo = 'API returned error: ${result['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Exception: ${e.toString()}';
        _isLoading = false;
        _debugInfo = 'Exception occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fundi Feed Debug'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadFundis),
        ],
      ),
      body: Column(
        children: [
          // Debug Info Panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Debug Information:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _debugInfo,
                  style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Loading: $_isLoading, Fundis: ${_fundis.length}, Error: $_error',
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading fundis...');
    }

    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _loadFundis);
    }

    if (_fundis.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No fundis found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _fundis.length,
      itemBuilder: (context, index) {
        final fundi = _fundis[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                fundi.name.isNotEmpty ? fundi.name[0].toUpperCase() : 'F',
              ),
            ),
            title: Text(fundi.name),
            subtitle: Text('Rating: ${fundi.rating}'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }
}
