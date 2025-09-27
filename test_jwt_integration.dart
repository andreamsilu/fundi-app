import 'package:flutter/material.dart';
import 'lib/core/config/env_config.dart';
import 'lib/core/network/api_client.dart';
import 'lib/features/auth/services/auth_service.dart';
import 'lib/core/services/jwt_token_manager.dart';

/// Test JWT Integration with the API
/// This file tests the JWT authentication flow
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== JWT INTEGRATION TEST ===');
  
  try {
    // Initialize environment configuration
    await EnvConfig.initialize();
    print('✅ Environment configuration initialized');
    print('API Base URL: ${EnvConfig.apiBaseUrl}');
    
    // Initialize API client
    final apiClient = ApiClient();
    await apiClient.initialize();
    print('✅ API client initialized');
    
    // Initialize JWT token manager
    final jwtManager = JwtTokenManager();
    print('✅ JWT token manager initialized');
    
    // Initialize auth service
    final authService = AuthService();
    await authService.initialize();
    print('✅ Auth service initialized');
    
    // Test login with JWT API
    print('\n--- Testing JWT Login ---');
    final loginResult = await authService.login(
      phoneNumber: '0754289824', // Admin user
      password: 'password123',
    );
    
    if (loginResult.success) {
      print('✅ JWT Login successful');
      print('User: ${loginResult.user?.displayName}');
      print('Roles: ${loginResult.user?.roles.map((r) => r.value).join(', ')}');
      print('Is Admin: ${loginResult.user?.isAdmin}');
      print('Is Customer: ${loginResult.user?.isCustomer}');
      print('Is Fundi: ${loginResult.user?.isFundi}');
      
      // Test JWT token info
      print('\n--- JWT Token Information ---');
      final tokenInfo = jwtManager.getTokenInfo();
      print('Token Info: $tokenInfo');
      
      // Test API call with JWT token
      print('\n--- Testing API Call with JWT Token ---');
      try {
        final response = await apiClient.get<Map<String, dynamic>>(
          '/users/me',
          fromJson: (data) => data as Map<String, dynamic>,
        );
        
        if (response.success) {
          print('✅ API call successful with JWT token');
          print('Response: ${response.data}');
        } else {
          print('❌ API call failed: ${response.message}');
        }
      } catch (e) {
        print('❌ API call error: $e');
      }
      
      // Test job feeds endpoint
      print('\n--- Testing Job Feeds Endpoint ---');
      try {
        final response = await apiClient.get<Map<String, dynamic>>(
          '/feeds/jobs',
          fromJson: (data) => data as Map<String, dynamic>,
        );
        
        if (response.success) {
          print('✅ Job feeds API call successful');
          print('Jobs count: ${response.data?['data']?.length ?? 0}');
        } else {
          print('❌ Job feeds API call failed: ${response.message}');
        }
      } catch (e) {
        print('❌ Job feeds API call error: $e');
      }
      
    } else {
      print('❌ JWT Login failed: ${loginResult.message}');
    }
    
    // Test logout
    print('\n--- Testing JWT Logout ---');
    await authService.logout();
    print('✅ Logout completed');
    
    print('\n=== JWT INTEGRATION TEST COMPLETED ===');
    
  } catch (e) {
    print('❌ JWT Integration test failed: $e');
  }
}
