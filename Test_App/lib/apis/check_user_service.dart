import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:school_scout/constants/login_common_api_call.dart';

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';

class CheckUserService {
  final String _baseUrl = ApiEndpoints.checkUser;

  Future<Map<String, dynamic>> checkUser(
      String role,
      String mobileNumber,
      String userId
      ) async {
    try {
      // Initialize API service
      final loginCommonApiCall = LoginCommonApiCall(baseUrl: _baseUrl);

      // Request payload
      final requestPayload = {
        "serviceName": "CheckAndRegister",
        "pin": "",
        "appId": "SID",
        "mobNumber": mobileNumber,
        "appVersion": "",
        "email": "",
        "firstName": "",
        "gender": "",
        "lastName": "",
        "userId": userId,
        "userPic": "",
        "userName": "",
        "roles": role,
        "userDob": "",
        "userAppVersion": "",
        "maker": "Y",
        "checker": "N"
      };

      print("CheckUser Request: $requestPayload");

      // Call the API
      final response = await loginCommonApiCall.post(requestPayload);
      print('CheckUser Response: $response');

      final statusCode = response['statusCode'] ?? '';
      final mobileExists = response['mobileExists'] ?? false;

      // ✅ CASE 0: Full user details (if API returns userDetails array)
      if (response.containsKey('userDetails') && response['userDetails'] != null) {
        return {
          'success': true,
          'statusCode': statusCode,
          'type': 'fullUser',
          'userDetails': response['userDetails'],
        };
      }

      // ✅ CASE 1: statusCode = "500" (User NOT found)
      if (statusCode == '500') {
        return {
          'success': false,
          'statusCode': '500',
          'type': 'notFound',
          'message': response['message'] ?? 'No records found',
          'mobileExists': false,
        };
      }

      // ✅ CASE 2: statusCode = "200" + mobileExists = true (User exists with mobile)
      if (statusCode == '200' && mobileExists == true) {
        return {
          'success': true,
          'statusCode': '200',
          'type': 'userExists',
          'userId': response['userId'] ?? '',
          'mobileNumber': response['mobNum'] ?? mobileNumber,
          'mobileExists': true,
          'message': response['message'] ?? 'User Id Exists',
        };
      }


      // Fallback for any unexpected response
      return {
        'success': false,
        'statusCode': statusCode,
        'type': 'unknown',
        'message': response['message'] ?? 'Unexpected response',
        'mobileExists': false,
      };

    } catch (e) {
      // ❌ Network or parsing error
      print('❌ CheckUser Error: $e');
      return {
        'success': false,
        'statusCode': 'ERROR',
        'type': 'exception',
        'message': 'Network error. Please check your connection.',
        'mobileExists': false,
        'error': e.toString(),
      };
    }
  }
}