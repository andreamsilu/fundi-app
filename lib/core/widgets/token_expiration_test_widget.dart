import 'package:flutter/material.dart';
import '../utils/token_expiration_test.dart';
import '../utils/logger.dart';

/// Widget for testing token expiration functionality
/// This widget provides buttons to test various token expiration scenarios
class TokenExpirationTestWidget extends StatefulWidget {
  const TokenExpirationTestWidget({super.key});

  @override
  State<TokenExpirationTestWidget> createState() =>
      _TokenExpirationTestWidgetState();
}

class _TokenExpirationTestWidgetState extends State<TokenExpirationTestWidget> {
  bool _isLoading = false;
  Map<String, dynamic> _debugInfo = {};

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final info = TokenExpirationTest.getTokenDebugInfo();
      setState(() {
        _debugInfo = info;
      });
    } catch (e) {
      Logger.error(
        'TokenExpirationTestWidget: Error loading debug info',
        error: e,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runTest(
    Future<void> Function() testFunction,
    String testName,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await testFunction();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$testName completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      Logger.error(
        'TokenExpirationTestWidget: Error running $testName',
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error running $testName: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      _loadDebugInfo(); // Refresh debug info
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Expiration Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Debug Info Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Token Debug Info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          _debugInfo.toString(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadDebugInfo,
                      child: const Text('Refresh Debug Info'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Buttons Section
            const Text(
              'Token Expiration Tests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _runTest(
                      TokenExpirationTest.testTokenExpiration,
                      'Token Expiration Test',
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Test Token Expiration'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _runTest(
                      TokenExpirationTest.testForceLogout,
                      'Force Logout Test',
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Test Force Logout'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _runTest(
                      TokenExpirationTest.testNavigationRedirect,
                      'Navigation Redirect Test',
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Test Navigation Redirect'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _runTest(
                      TokenExpirationTest.testTokenExpirationDialog,
                      'Dialog Test',
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Test Token Expiration Dialog'),
            ),
            const SizedBox(height: 16),

            // Run All Tests Button
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () =>
                        _runTest(TokenExpirationTest.runAllTests, 'All Tests'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Run All Tests',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Warning Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow[300]!),
              ),
              child: const Text(
                'Warning: These tests will trigger actual token expiration handling, '
                'including redirects to the login screen and clearing of session data. '
                'Use with caution in production environments.',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


