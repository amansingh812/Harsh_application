import '../constants/api_endpoints.dart';
import '../constants/login_common_api_call.dart';

class ResetPinService {
  final String _baseUrl = ApiEndpoints.resetPinUrl;

  /// 🔐 RESET PIN API
  Future<Map<String, dynamic>> resetPin(
      String mobNumber,
      String newPin,
      ) async {
    try {
      final apiService = LoginCommonApiCall(
        baseUrl: _baseUrl,
      );

      final requestPayload = {
        "newPin": newPin,
        "appId": "SID",
        "mobNumber": mobNumber,
      };

      final response = await apiService.post(requestPayload);

      if (response['statusCode'] == '200') {
        return {
          'success': true,
          'message': response['statusDesc'] ?? 'PIN reset successful',
        };
      }

      // 🔥 HANDLE BACKEND ERROR PROPERLY
      return {
        'success': false,
        'message': response['message'] ?? response['statusDesc'] ?? 'Something went wrong',
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Server error. Please try again.',
      };
    }
  }
}
