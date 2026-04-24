import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';

class UpdatePinService {
  final String baseUrl = ApiEndpoints.updatePinURL;

  /// 🔐 UPDATE PIN
  Future<Map<String, dynamic>> updatePin({
    required String mobNumber,
    required String oldPin,
    required String newPin,
  }) async {
    try {
      final commonApiCall = CommonApiCall(
        baseUrl: baseUrl,
      );

      final requestPayload = {
        "oldPin": oldPin,
        "newPin": newPin,
        "appId": "SID",
        "mobNumber": mobNumber,
      };

      final response = await commonApiCall.post(requestPayload);

      print('Decrypted response: $response');

      if (response["statusCode"] == "200") {
        return {
          "success": true,
          "message": response["message"] ?? "PIN updated successfully",
        };
      }

      // 🔥 backend failure (500 etc.)
      return {
        "success": false,
        "message": response["message"] ??
            response["statusDesc"] ??
            "PIN update failed",
      };
    } catch (e) {
      print('Error: $e');
      return {
        "success": false,
        "message": "Server error. Please try again later.",
      };
    }
  }
}
