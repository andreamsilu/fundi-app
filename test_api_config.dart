// Simple test to verify API configuration without Flutter dependencies
import 'dart:io';
import 'dart:convert';

void main() async {
  print('=== API Configuration Test ===');
  
  // Test the production API directly
  final apiUrl = 'http://185.213.27.206:8081/api';
  print('Testing API URL: $apiUrl');
  
  try {
    // Test health endpoint
    print('\n1. Testing health endpoint...');
    final healthResponse = await _makeRequest('$apiUrl/health');
    print('Health response: $healthResponse');
    
    // Test login endpoint
    print('\n2. Testing login endpoint...');
    final loginData = {
      'phone': '0754289824',
      'password': 'password123'
    };
    
    final loginResponse = await _makeRequest(
      '$apiUrl/auth/login',
      method: 'POST',
      body: jsonEncode(loginData),
      headers: {'Content-Type': 'application/json'}
    );
    print('Login response: $loginResponse');
    
    print('\n=== Test completed successfully ===');
    
  } catch (e) {
    print('Error testing API: $e');
  }
}

Future<String> _makeRequest(String url, {String method = 'GET', String? body, Map<String, String>? headers}) async {
  final client = HttpClient();
  try {
    final request = await client.openUrl(method, Uri.parse(url));
    
    if (headers != null) {
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });
    }
    
    if (body != null) {
      request.write(body);
    }
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    return 'Status: ${response.statusCode}, Body: $responseBody';
  } finally {
    client.close();
  }
}
