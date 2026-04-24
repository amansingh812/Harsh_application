import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_scout/global/global_data.dart';

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';
import '../constants/login_common_api_call.dart';

class RegistrationService {
  final String _baseUrl =
      ApiEndpoints.registerURl; // Replace with your API URL

  Future<Map<String, dynamic>> registerUser(
    String userId,
    String mobNumber,
    String pin,
  ) async {
    try {
      // Initialize CommonApiCall
      final loginCommonApiCall = LoginCommonApiCall(baseUrl: _baseUrl);

      // Construct the request payload
      final requestPayload = {
        "serviceName": "CheckAndRegister",
        "pin": pin,
        "appId": "SID",
        "mobNumber": mobNumber,
        "appVersion": "",
        "email": "",
        "firstName": "",
        "gender": "",
        "lastName": "",
        "userId": userId,
        "userPic": "",
        "userName": "",
        "roles": "",
        "userDob": "",
        "userAppVersion": "",
        "maker": "Y",
        "checker": "N"
      };


      // Make the API call using CommonApiCall
      final response = await loginCommonApiCall.post(requestPayload);
      print('Decrypted response: $response');

      if (response['statusCode'] == 200 || response['statusCode'] == '200') {
        return {
          'success': true,
          'message': response['statusDesc'],
          'userId': response['userId'],
          'mobileExists': response['mobileExists'],
        };
      }
      else {
        return {
          'success': false,
          'message': response['statusDesc'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('Error during registration: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
