import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/app/app_config.dart';
import 'core/app/app_initializer.dart';
import 'core/routing/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/job/providers/job_provider.dart';
import 'features/portfolio/providers/portfolio_provider.dart';
import 'features/messaging/providers/messaging_provider.dart';

/// Main entry point of the Fundi App
/// Initializes the app with proper theme, providers, and routing
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration
  await AppConfig.initialize();

  // Initialize API client
  await ApiClient().initialize();

  runApp(const FundiApp());
}

class FundiApp extends StatelessWidget {
  const FundiApp({super.key});

  @override
  Widget build(BuildContext context) {
    print(
      'Creating MultiProvider with ${AppConfig.providers.length} providers',
    );

    // Create providers directly for debugging
    final providers = [
      ChangeNotifierProvider(
        create: (_) {
          print('Creating AuthProvider instance');
          return AuthProvider();
        },
      ),
      ChangeNotifierProvider(
        create: (_) {
          print('Creating JobProvider instance');
          return JobProvider();
        },
      ),
      ChangeNotifierProvider(
        create: (_) {
          print('Creating PortfolioProvider instance');
          return PortfolioProvider();
        },
      ),
      ChangeNotifierProvider(
        create: (_) {
          print('Creating MessagingProvider instance');
          return MessagingProvider();
        },
      ),
    ];

    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: AppConfig.appTitle,
        debugShowCheckedModeBanner: AppConfig.showDebugBanner,
        theme: AppConfig.lightTheme,
        darkTheme: AppConfig.darkTheme,
        themeMode: ThemeMode.light,
        home: const AppInitializer(),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppConfig.initialRoute,
      ),
    );
  }
}

class SimpleLoginTest extends StatelessWidget {
  const SimpleLoginTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Logo and title
              Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.build,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fundi App',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Connect with skilled craftsmen',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Phone field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Password field
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: const Icon(Icons.visibility_off),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?'),
                ),
              ),

              const SizedBox(height: 24),

              // Login button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Login'),
              ),

              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              // Register button
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Create Account'),
              ),

              const SizedBox(height: 24),

              // Terms and privacy
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProviderTestWidget extends StatelessWidget {
  const ProviderTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    print('ProviderTestWidget build called');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('SUCCESS: AuthProvider found: ${authProvider.runtimeType}');

      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Provider Test - SUCCESS!'),
              Text('AuthProvider: ${authProvider.runtimeType}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AppInitializer()),
                  );
                },
                child: const Text('Go to AppInitializer'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('ERROR: AuthProvider not found: $e');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Provider Test - FAILED!'),
              Text('Error: $e'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AppInitializer()),
                  );
                },
                child: const Text('Try AppInitializer anyway'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
