import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Portfolio screen for viewing and managing portfolios
class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add portfolio screen
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Portfolio Screen\nComing Soon!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: AppTheme.mediumGray),
        ),
      ),
    );
  }
}
