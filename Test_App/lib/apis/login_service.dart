import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';
import '../global/global_data.dart';
import '../constants/login_common_api_call.dart';

class LoginService {
  final String _baseUrl =
      '${ApiEndpoints.loginURl}'; // Replace with your API URL


  Future<Map<String, dynamic>> loginUser(String mobNumber, String pin,
      String userId) async {
    try {
      final apiService = LoginCommonApiCall(
        baseUrl: _baseUrl,
      );

      final requestPayload = {
        "serviceName": ApiEndpoints.login,
        "pin": pin,
        "appId": "SID",
        "mobNumber": mobNumber,
        "userId": userId
      };

      final response = await apiService.post(requestPayload);

      if (response['statusCode']?.toString() == '200') {
        final List details = response['userDetails'] ?? [];

        if (details.isEmpty) {
          return {
            'success': false,
            'message': 'User data not found',
          };
        }

        final user = details.first;

        return {
          'success': true,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': response['statusDesc'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
