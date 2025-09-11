import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/payment_model.dart';

/// Payment service for handling payment-related API calls
class PaymentService {
  final ApiClient _apiClient = ApiClient();

  /// Get user payments
  Future<ApiResponse<List<PaymentModel>>> getUserPayments({
    int page = 1,
    int limit = 15,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.payments,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.success) {
        final List<dynamic> paymentsData = response.data['data']['data'] ?? [];
        final payments = paymentsData
            .map((json) => PaymentModel.fromJson(json))
            .toList();

        return ApiResponse<List<PaymentModel>>(
          success: true,
          data: payments,
          message: response.data['message'],
        );
      } else {
        return ApiResponse<List<PaymentModel>>(
          success: false,
          message: response.data['message'] ?? 'Failed to fetch payments',
        );
      }
    } catch (e) {
      Logger.error('Get user payments error', error: e);
      return ApiResponse<List<PaymentModel>>(
        success: false,
        message: 'An error occurred while fetching payments',
      );
    }
  }

  /// Create payment
  Future<ApiResponse<PaymentModel>> createPayment({
    required double amount,
    required String paymentType,
    required String pesapalReference,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createPayment,
        data: {
          'amount': amount,
          'payment_type': paymentType,
          'pesapal_reference': pesapalReference,
        },
      );

      if (response.success) {
        final payment = PaymentModel.fromJson(response.data['data']);
        return ApiResponse<PaymentModel>(
          success: true,
          data: payment,
          message: response.data['message'],
        );
      } else {
        return ApiResponse<PaymentModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to create payment',
        );
      }
    } catch (e) {
      Logger.error('Create payment error', error: e);
      return ApiResponse<PaymentModel>(
        success: false,
        message: 'An error occurred while creating payment',
      );
    }
  }

  /// Get payment requirements
  Future<ApiResponse<PaymentRequirementsModel>> getPaymentRequirements() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.paymentRequirements);

      if (response.success) {
        final requirements = PaymentRequirementsModel.fromJson(response.data['data']);
        return ApiResponse<PaymentRequirementsModel>(
          success: true,
          data: requirements,
          message: response.data['message'],
        );
      } else {
        return ApiResponse<PaymentRequirementsModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to fetch payment requirements',
        );
      }
    } catch (e) {
      Logger.error('Get payment requirements error', error: e);
      return ApiResponse<PaymentRequirementsModel>(
        success: false,
        message: 'An error occurred while fetching payment requirements',
      );
    }
  }

  /// Check if payment is required for specific action
  Future<ApiResponse<PaymentValidationModel>> checkPaymentRequired({
    required String action,
    String? jobId,
  }) async {
    try {
      final data = {
        'action': action,
      };
      
      if (jobId != null) {
        data['job_id'] = jobId;
      }

      final response = await _apiClient.post(
        ApiEndpoints.checkPaymentRequired,
        data: data,
      );

      if (response.success) {
        final validation = PaymentValidationModel.fromJson(response.data['data']);
        return ApiResponse<PaymentValidationModel>(
          success: true,
          data: validation,
          message: response.data['message'],
        );
      } else {
        return ApiResponse<PaymentValidationModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to validate payment',
        );
      }
    } catch (e) {
      Logger.error('Check payment required error', error: e);
      return ApiResponse<PaymentValidationModel>(
        success: false,
        message: 'An error occurred while validating payment',
      );
    }
  }

  /// Process payment with Pesapal
  Future<ApiResponse<Map<String, dynamic>>> processPesapalPayment({
    required double amount,
    required String paymentType,
    required String phoneNumber,
    required String email,
    String? description,
  }) async {
    try {
      // This would integrate with Pesapal API
      // For now, we'll simulate the process
      final pesapalReference = 'PESAPAL_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create payment record
      final paymentResponse = await createPayment(
        amount: amount,
        paymentType: paymentType,
        pesapalReference: pesapalReference,
      );

      if (paymentResponse.success) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: {
            'payment_id': paymentResponse.data!.id,
            'pesapal_reference': pesapalReference,
            'amount': amount,
            'payment_type': paymentType,
            'redirect_url': 'https://pesapal.com/payment/$pesapalReference',
          },
          message: 'Payment initiated successfully',
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: paymentResponse.message,
        );
      }
    } catch (e) {
      Logger.error('Process Pesapal payment error', error: e);
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'An error occurred while processing payment',
      );
    }
  }

  /// Verify payment status
  Future<ApiResponse<PaymentModel>> verifyPaymentStatus({
    required String pesapalReference,
  }) async {
    try {
      // This would check with Pesapal API for actual payment status
      // For now, we'll simulate a successful payment
      final response = await _apiClient.get('/payments/verify/$pesapalReference');

      if (response.success) {
        final payment = PaymentModel.fromJson(response.data['data']);
        return ApiResponse<PaymentModel>(
          success: true,
          data: payment,
          message: response.data['message'],
        );
      } else {
        return ApiResponse<PaymentModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to verify payment',
        );
      }
    } catch (e) {
      Logger.error('Verify payment status error', error: e);
      return ApiResponse<PaymentModel>(
        success: false,
        message: 'An error occurred while verifying payment',
      );
    }
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
  });
}
