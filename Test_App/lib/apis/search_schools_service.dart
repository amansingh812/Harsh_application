import 'dart:convert';

import '../constants/common_api_call.dart';
import '../constants/api_endpoints.dart';
import '../constants/encryption_logic.dart';

class SearchSchoolsService {
  final String baseUrl = ApiEndpoints.searchSchoolsURL;

  Future<Map<String, dynamic>> searchSchools({
    required String city,
    required String area,
    required String board,
    required String schoolName,
    required String pinCode,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final commonApiCall = CommonApiCall(baseUrl: baseUrl);

      final requestPayload = {
        "city": city,
        "area": area,
        "board": board,
        "schoolName": schoolName,
        "pinCode": pinCode,
        "limit": limit,
        "offset": offset,
      };
      print('Original body: $requestPayload');
      String encryptedBody = EncryptionUtils.encrypt(jsonEncode(requestPayload));
      print('Encrypted request: $encryptedBody');
      print('Encrypted  body: $requestPayload');
      final response = await commonApiCall.post(requestPayload);

      print('Decrypted response: $response');

      if (response['statusCode'] == '200') {
        return response; // ✅ SAME AS APISERVICE
      }

      return {
        "success": false,
        "message": response['message'] ??
            response['statusDesc'] ??
            'Search failed',
      };
    } catch (e) {
      print('Error: $e');
      return {
        "success": false,
        "message": 'Server error. Please try again.',
      };
    }
  }
}
