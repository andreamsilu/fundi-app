import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/logger.dart';

/// ZenoPay Mobile Money Payment Service
/// Handles integration with ZenoPay for Tanzania mobile money payments
/// Supports M-Pesa, Tigo Pesa, and Airtel Money
class ZenoPayService {
  static final ZenoPayService _instance = ZenoPayService._internal();
  factory ZenoPayService() => _instance;
  ZenoPayService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Initiate mobile money payment
  Future<ZenoPayResult> initiatePayment({
    required double amount,
    required String phoneNumber,
    required String buyerName,
    required String buyerEmail,
    required String
    paymentType, // 'subscription', 'job_payment', 'application_fee'
    String? referenceId,
  }) async {
    try {
      Logger.userAction(
        'Initiating ZenoPay payment',
        data: {
          'amount': amount,
          'payment_type': paymentType,
          'phone': phoneNumber,
        },
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.zenoPayInitiate,
        {},
        {
          'amount': amount,
          'phone_number': phoneNumber,
          'buyer_name': buyerName,
          'buyer_email': buyerEmail,
          'payment_type': paymentType,
          if (referenceId != null) 'reference_id': referenceId,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        Logger.userAction(
          'ZenoPay payment initiated',
          data: {'order_id': response.data!['order_id']},
        );

        return ZenoPayResult.success(
          orderId: response.data!['order_id'] as String,
          amount: response.data!['amount'] as num,
          phoneNumber: response.data!['phone_number'] as String,
          status: response.data!['status'] as String,
          instructions:
              response.data!['instructions'] as String? ??
              'Check your phone for payment prompt',
          message: response.message,
        );
      } else {
        Logger.warning(
          'ZenoPay payment initiation failed: ${response.message}',
        );
        return ZenoPayResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('ZenoPay initiation API error', error: e);
      return ZenoPayResult.failure(message: e.message);
    } catch (e) {
      Logger.error('ZenoPay initiation unexpected error', error: e);
      return ZenoPayResult.failure(
        message: 'Payment initiation failed. Please try again.',
      );
    }
  }

  /// Check payment status
  Future<ZenoPayStatusResult> checkPaymentStatus(String orderId) async {
    try {
      Logger.userAction('Checking ZenoPay status', data: {'order_id': orderId});

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getZenoPayStatusEndpoint(orderId),
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final orderData = response.data!;
        final paymentStatus = orderData['payment_status'] as String?;

        Logger.userAction(
          'ZenoPay status retrieved',
          data: {'order_id': orderId, 'status': paymentStatus},
        );

        return ZenoPayStatusResult.success(
          orderId: orderData['order_id'] as String,
          paymentStatus: paymentStatus ?? 'UNKNOWN',
          amount: orderData['amount'] as String?,
          channel: orderData['channel'] as String?,
          reference: orderData['reference'] as String?,
          transactionId: orderData['transid'] as String?,
          creationDate: orderData['creation_date'] as String?,
        );
      } else {
        Logger.warning('ZenoPay status check failed: ${response.message}');
        return ZenoPayStatusResult.failure(message: response.message);
      }
    } on ApiError catch (e) {
      Logger.error('ZenoPay status check API error', error: e);
      return ZenoPayStatusResult.failure(message: e.message);
    } catch (e) {
      Logger.error('ZenoPay status check unexpected error', error: e);
      return ZenoPayStatusResult.failure(
        message: 'Status check failed. Please try again.',
      );
    }
  }

  /// Get supported mobile money providers
  Future<List<MobileMoneyProvider>> getSupportedProviders() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.zenoPayProviders,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final providers = <MobileMoneyProvider>[];
        response.data!.forEach((key, value) {
          providers.add(MobileMoneyProvider(code: key, name: value as String));
        });
        return providers;
      }

      return [];
    } catch (e) {
      Logger.error('Get providers error', error: e);
      return [];
    }
  }

  /// Validate Tanzanian phone number
  bool isValidTanzanianPhone(String phone) {
    // Remove spaces, dashes, plus
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\+]'), '');

    // Valid formats: 07XXXXXXXX or 2557XXXXXXXX
    final pattern = RegExp(r'^(07[0-9]{8}|2557[0-9]{8})$');
    return pattern.hasMatch(cleaned);
  }

  /// Format phone number to ZenoPay format (07XXXXXXXX)
  String? formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\+]'), '');

    // If starts with 255, convert to 0
    String formatted = cleaned;
    if (formatted.startsWith('255')) {
      formatted = '0${formatted.substring(3)}';
    }

    return isValidTanzanianPhone(formatted) ? formatted : null;
  }
}

/// ZenoPay payment initiation result
class ZenoPayResult {
  final bool success;
  final String? orderId;
  final num? amount;
  final String? phoneNumber;
  final String? status;
  final String? instructions;
  final String message;

  ZenoPayResult._({
    required this.success,
    this.orderId,
    this.amount,
    this.phoneNumber,
    this.status,
    this.instructions,
    required this.message,
  });

  factory ZenoPayResult.success({
    required String orderId,
    required num amount,
    required String phoneNumber,
    required String status,
    String? instructions,
    required String message,
  }) {
    return ZenoPayResult._(
      success: true,
      orderId: orderId,
      amount: amount,
      phoneNumber: phoneNumber,
      status: status,
      instructions: instructions,
      message: message,
    );
  }

  factory ZenoPayResult.failure({required String message}) {
    return ZenoPayResult._(success: false, message: message);
  }
}

/// ZenoPay payment status result
class ZenoPayStatusResult {
  final bool success;
  final String? orderId;
  final String? paymentStatus; // PENDING, COMPLETED, FAILED
  final String? amount;
  final String? channel; // MPESA-TZ, TIGO-TZ, AIRTEL-TZ
  final String? reference;
  final String? transactionId;
  final String? creationDate;
  final String message;

  ZenoPayStatusResult._({
    required this.success,
    this.orderId,
    this.paymentStatus,
    this.amount,
    this.channel,
    this.reference,
    this.transactionId,
    this.creationDate,
    required this.message,
  });

  factory ZenoPayStatusResult.success({
    required String orderId,
    required String paymentStatus,
    String? amount,
    String? channel,
    String? reference,
    String? transactionId,
    String? creationDate,
  }) {
    return ZenoPayStatusResult._(
      success: true,
      orderId: orderId,
      paymentStatus: paymentStatus,
      amount: amount,
      channel: channel,
      reference: reference,
      transactionId: transactionId,
      creationDate: creationDate,
      message: 'Status retrieved successfully',
    );
  }

  factory ZenoPayStatusResult.failure({required String message}) {
    return ZenoPayStatusResult._(success: false, message: message);
  }

  /// Check if payment is completed
  bool get isCompleted => paymentStatus == 'COMPLETED';

  /// Check if payment is pending
  bool get isPending => paymentStatus == 'PENDING';

  /// Check if payment is failed
  bool get isFailed => paymentStatus == 'FAILED';
}

/// Mobile money provider
class MobileMoneyProvider {
  final String code;
  final String name;

  MobileMoneyProvider({required this.code, required this.name});

  /// Get provider logo/icon
  String get icon {
    switch (code) {
      case 'MPESA-TZ':
        return 'assets/images/mpesa_logo.png';
      case 'TIGO-TZ':
        return 'assets/images/tigo_logo.png';
      case 'AIRTEL-TZ':
        return 'assets/images/airtel_logo.png';
      default:
        return 'assets/images/payment_default.png';
    }
  }
}


