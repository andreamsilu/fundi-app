import 'package:flutter/material.dart';
import 'splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';

/// Test widget to verify the app flow sequence
/// Shows: Splash → Onboarding → Login
class AppFlowTest extends StatefulWidget {
  const AppFlowTest({super.key});

  @override
  State<AppFlowTest> createState() => _AppFlowTestState();
}

class _AppFlowTestState extends State<AppFlowTest> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Splash Screen',
    'Onboarding Screen',
    'Login Screen',
  ];

  @override
  void initState() {
    super.initState();
    _simulateAppFlow();
  }

  Future<void> _simulateAppFlow() async {
    // Step 1: Show splash screen for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _currentStep = 1);
    }

    // Step 2: Show onboarding screen for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _currentStep = 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Flow Test - ${_steps[_currentStep]}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Current Step: ${_currentStep + 1}/${_steps.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _steps.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 16),
                Text(
                  _steps[_currentStep],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // Current screen content
          Expanded(child: _buildCurrentScreen()),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentStep) {
      case 0:
        return SplashScreen();
      case 1:
        return const OnboardingScreen();
      case 2:
        return const LoginScreen();
      default:
        return const Center(child: Text('App flow completed!'));
    }
  }
}
