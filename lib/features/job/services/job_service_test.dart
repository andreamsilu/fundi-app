import 'job_service.dart';
import '../models/job_model.dart';

/// Test class for JobService to verify API integration
class JobServiceTest {
  static final JobService _jobService = JobService();

  /// Test job creation with the exact API format
  static Future<void> testCreateJob() async {
    print('🧪 Testing Job Creation with API Format...');

    try {
      final result = await _jobService.createJob(
        title: 'Fix Leaky Faucet',
        description: 'Need to fix a leaky faucet in the kitchen',
        categoryId: 1, // Plumbing category
        location: 'Dar es Salaam',
        budget: 25000.0,
        budgetType: 'fixed',
        deadline: DateTime(2025, 12, 31),
        urgency: 'medium',
        requiredSkills: ['plumbing', 'repair'],
      );

      if (result.success) {
        print('✅ Job created successfully!');
        print('Job ID: ${result.job?.id}');
        print('Title: ${result.job?.title}');
        print('Category: ${result.job?.categoryName}');
        print('Budget: ${result.job?.formattedBudget}');
        print('Deadline: ${result.job?.formattedDeadline}');
        print('Status: ${result.job?.status}');
      } else {
        print('❌ Job creation failed: ${result.message}');
      }
    } catch (e) {
      print('❌ Error testing job creation: $e');
    }
  }

  /// Test job creation with different urgency levels
  static Future<void> testCreateJobWithUrgency() async {
    print('🧪 Testing Job Creation with Different Urgency Levels...');

    final urgencies = ['low', 'medium', 'high'];

    for (final urgency in urgencies) {
      try {
        final result = await _jobService.createJob(
          title: 'Test Job - $urgency urgency',
          description: 'Test job with $urgency urgency level',
          categoryId: 1,
          location: 'Dar es Salaam',
          budget: 15000.0,
          budgetType: 'fixed',
          deadline: DateTime.now().add(const Duration(days: 7)),
          urgency: urgency,
        );

        if (result.success) {
          print('✅ Job created with $urgency urgency: ${result.job?.id}');
        } else {
          print(
            '❌ Failed to create job with $urgency urgency: ${result.message}',
          );
        }
      } catch (e) {
        print('❌ Error creating job with $urgency urgency: $e');
      }
    }
  }

  /// Test job creation with different categories
  static Future<void> testCreateJobWithCategories() async {
    print('🧪 Testing Job Creation with Different Categories...');

    final categories = [
      {'id': 1, 'name': 'Plumbing'},
      {'id': 2, 'name': 'Electrical'},
      {'id': 3, 'name': 'Carpentry'},
    ];

    for (final category in categories) {
      try {
        final result = await _jobService.createJob(
          title: 'Test ${category['name']} Job',
          description: 'Test job for ${category['name']} category',
          categoryId: category['id'] as int,
          location: 'Dar es Salaam',
          budget: 20000.0,
          budgetType: 'fixed',
          deadline: DateTime.now().add(const Duration(days: 14)),
          urgency: 'medium',
        );

        if (result.success) {
          print('✅ Job created for ${category['name']}: ${result.job?.id}');
        } else {
          print(
            '❌ Failed to create job for ${category['name']}: ${result.message}',
          );
        }
      } catch (e) {
        print('❌ Error creating job for ${category['name']}: $e');
      }
    }
  }

  /// Test job creation with location coordinates
  static Future<void> testCreateJobWithLocation() async {
    print('🧪 Testing Job Creation with Location Coordinates...');

    try {
      final result = await _jobService.createJob(
        title: 'Test Job with Location',
        description: 'Test job with specific location coordinates',
        categoryId: 1,
        location: 'Dar es Salaam',
        budget: 30000.0,
        budgetType: 'fixed',
        deadline: DateTime.now().add(const Duration(days: 10)),
        urgency: 'high',
        latitude: -6.7924,
        longitude: 39.2083,
      );

      if (result.success) {
        print('✅ Job created with location: ${result.job?.id}');
        print('Location: ${result.job?.location}');
        print('Lat: ${result.job?.locationLat}');
        print('Lng: ${result.job?.locationLng}');
      } else {
        print('❌ Failed to create job with location: ${result.message}');
      }
    } catch (e) {
      print('❌ Error creating job with location: $e');
    }
  }

  /// Run all tests
  static Future<void> runAllTests() async {
    print('🚀 Starting Job Service Tests...\n');

    await testCreateJob();
    print('');

    await testCreateJobWithUrgency();
    print('');

    await testCreateJobWithCategories();
    print('');

    await testCreateJobWithLocation();
    print('');

    print('🏁 Job Service Tests Completed!');
  }
}

