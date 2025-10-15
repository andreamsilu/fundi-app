import 'package:flutter/material.dart';
import '../services/portfolio_service.dart';

/// Widget to demonstrate the enhanced Future.wait pattern
/// Shows how to load feed data with error handling and fallbacks
class FeedDataWidget extends StatefulWidget {
  const FeedDataWidget({super.key});

  @override
  State<FeedDataWidget> createState() => _FeedDataWidgetState();
}

class _FeedDataWidgetState extends State<FeedDataWidget> {
  final PortfolioService _portfolioService = PortfolioService();
  FeedDataState _state = const FeedDataState();
  
  @override
  void initState() {
    super.initState();
    _loadFeedData();
  }
  
  Future<void> _loadFeedData() async {
    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });
    
    try {
      final result = await _portfolioService.loadFeedDataWithRetry();
      
      if (result.success && result.data != null) {
        setState(() {
          _state = _state.copyWith(
            isLoading: false,
            data: result.data,
            lastUpdated: DateTime.now(),
          );
        });
      } else {
        setState(() {
          _state = _state.copyWith(
            isLoading: false,
            error: result.message,
          );
        });
      }
    } catch (e) {
      setState(() {
        _state = _state.copyWith(
          isLoading: false,
          error: 'An unexpected error occurred',
        );
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_state.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    if (_state.hasError) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                'Failed to load feed data',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                _state.error!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadFeedData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!_state.hasData) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No data available'),
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.data_object, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Feed Data',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_state.isStale)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'STALE',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildDataRow(
              'Categories',
              _state.data!.categories.length,
              Icons.category,
              Colors.green,
            ),
            
            _buildDataRow(
              'Skills',
              _state.data!.skills.length,
              Icons.build,
              Colors.blue,
            ),
            
            _buildDataRow(
              'Locations',
              _state.data!.locations.length,
              Icons.location_on,
              Colors.red,
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loadFeedData,
                    child: const Text('Refresh'),
                  ),
                ),
                const SizedBox(width: 8),
                if (_state.isStale)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loadFeedData,
                      child: const Text('Update Now'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDataRow(String label, int count, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '$count items',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
