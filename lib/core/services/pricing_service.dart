import '../network/api_client.dart';
import '../utils/logger.dart';

/// Service to fetch dynamic pricing from admin settings
/// This ensures pricing is always in sync with admin panel configuration
class PricingService {
  static final PricingService _instance = PricingService._internal();
  factory PricingService() => _instance;
  PricingService._internal();

  final ApiClient _apiClient = ApiClient();

  // Cache for pricing data (refresh every 5 minutes)
  PricingData? _cachedPricing;
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 5);

  /// Get current pricing from admin settings (API)
  /// This fetches pricing dynamically instead of using hardcoded values
  Future<PricingData> getPricing({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh &&
          _cachedPricing != null &&
          _lastFetch != null &&
          DateTime.now().difference(_lastFetch!) < _cacheDuration) {
        Logger.info('Using cached pricing data');
        return _cachedPricing!;
      }

      Logger.userAction('Fetching pricing from API');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/admin/settings/pricing',
      );

      if (response.success && response.data != null) {
        final pricingData = PricingData.fromJson(response.data!['pricing']);

        // Update cache
        _cachedPricing = pricingData;
        _lastFetch = DateTime.now();

        Logger.userAction('Pricing fetched successfully');
        return pricingData;
      } else {
        Logger.warning('Failed to fetch pricing: ${response.message}');

        // Return cached data if available
        if (_cachedPricing != null) {
          Logger.info('Using stale cached pricing data');
          return _cachedPricing!;
        }

        // Fall back to default pricing
        return PricingData.defaultPricing();
      }
    } on ApiError catch (e) {
      Logger.error('Pricing fetch API error', error: e);

      // Return cached or default
      return _cachedPricing ?? PricingData.defaultPricing();
    } catch (e) {
      Logger.error('Pricing fetch unexpected error', error: e);
      return _cachedPricing ?? PricingData.defaultPricing();
    }
  }

  /// Clear cached pricing (force refresh on next call)
  void clearCache() {
    _cachedPricing = null;
    _lastFetch = null;
    Logger.info('Pricing cache cleared');
  }

  /// Get pricing for specific action
  Future<double> getPriceFor(String action) async {
    final pricing = await getPricing();
    return pricing.getPrice(action);
  }
}

/// Pricing data model
class PricingData {
  final double jobApplicationFee;
  final double jobPostingFee;
  final double premiumProfileFee;
  final double featuredJobFee;
  final double subscriptionMonthlyFee;
  final double subscriptionYearlyFee;
  final double platformCommissionPercentage;

  const PricingData({
    required this.jobApplicationFee,
    required this.jobPostingFee,
    required this.premiumProfileFee,
    required this.featuredJobFee,
    required this.subscriptionMonthlyFee,
    required this.subscriptionYearlyFee,
    required this.platformCommissionPercentage,
  });

  factory PricingData.fromJson(Map<String, dynamic> json) {
    return PricingData(
      jobApplicationFee: (json['job_application_fee'] as num).toDouble(),
      jobPostingFee: (json['job_posting_fee'] as num).toDouble(),
      premiumProfileFee: (json['premium_profile_fee'] as num).toDouble(),
      featuredJobFee: (json['featured_job_fee'] as num).toDouble(),
      subscriptionMonthlyFee: (json['subscription_monthly_fee'] as num)
          .toDouble(),
      subscriptionYearlyFee: (json['subscription_yearly_fee'] as num)
          .toDouble(),
      platformCommissionPercentage:
          (json['platform_commission_percentage'] as num).toDouble(),
    );
  }

  /// Default fallback pricing (matches database defaults)
  factory PricingData.defaultPricing() {
    return const PricingData(
      jobApplicationFee: 200,
      jobPostingFee: 1000,
      premiumProfileFee: 500,
      featuredJobFee: 2000,
      subscriptionMonthlyFee: 5000,
      subscriptionYearlyFee: 50000,
      platformCommissionPercentage: 10,
    );
  }

  /// Get price for specific action
  double getPrice(String action) {
    switch (action) {
      case 'job_application':
      case 'fundi_application':
        return jobApplicationFee;
      case 'job_post':
      case 'job_posting':
        return jobPostingFee;
      case 'premium_profile':
        return premiumProfileFee;
      case 'featured_job':
        return featuredJobFee;
      case 'subscription_monthly':
        return subscriptionMonthlyFee;
      case 'subscription_yearly':
        return subscriptionYearlyFee;
      default:
        Logger.warning('Unknown pricing action: $action');
        return 0;
    }
  }

  /// Format price with currency
  String formatPrice(String action) {
    final price = getPrice(action);
    return 'TZS ${price.toStringAsFixed(0)}';
  }

  /// Calculate yearly savings percentage
  double getYearlySavingsPercentage() {
    final monthlyYearly = subscriptionMonthlyFee * 12;
    final savings = monthlyYearly - subscriptionYearlyFee;
    return (savings / monthlyYearly) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'job_application_fee': jobApplicationFee,
      'job_posting_fee': jobPostingFee,
      'premium_profile_fee': premiumProfileFee,
      'featured_job_fee': featuredJobFee,
      'subscription_monthly_fee': subscriptionMonthlyFee,
      'subscription_yearly_fee': subscriptionYearlyFee,
      'platform_commission_percentage': platformCommissionPercentage,
    };
  }
}
