import 'dart:developer' as dev;
import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';

class ReviewRatingService {
  final _baseUrl = ApiEndpoints.reviewRatingURL;

  /// Submits a rating and optional review for a school.
  /// Returns true on success, false on failure.
  Future<bool> submitReview({
    required String schoolId,
    required String userId,
    required int rating,
    String review = '',
  }) async {
    try {
      final commonApiCall = CommonApiCall(baseUrl: _baseUrl);
      final payload = {
        'schoolId': schoolId,
        'userId': userId,
        'rating': rating.toString(),
        'review': review,
      };

      dev.log('⭐ RATING API — REQUEST (decrypted): $payload', name: 'ReviewRatingService');

      final response = await commonApiCall.post(payload);

      dev.log('⭐ RATING API — RESPONSE (decrypted): $response', name: 'ReviewRatingService');

      return response['statusCode'] == '200';
    } catch (e) {
      dev.log('❌ RATING API — ERROR: $e', name: 'ReviewRatingService');
      return false;
    }
  }
}
