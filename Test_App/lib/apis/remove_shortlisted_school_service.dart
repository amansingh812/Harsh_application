import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';

class RemoveShortlistedSchoolService {
  final Dio _dio = Dio();
  final String _removeSchoolUrl =
      '${ApiEndpoints.baseUrl3}RemoveSchool'; // Replace with your API URL

  /* Future<Map<String, dynamic>> removeShortlistedSchool({
    required String schoolId,
    required String shortListedBy,
  }) async {
    final url = _removeSchoolUrl;

    try {
      // Prepare the request body
      final data = {
        "serviceName": "RemoveShortedSchool",
        "schoolId": schoolId,
        "shortListedBy": shortListedBy,
      };

      // Make the API request
      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // Handle the API response
      if (response.statusCode == 200) {
        final jsonResponse = response.data;

        if (jsonResponse['statusCode'] == '200') {
          return {
            'success': true,
            'message': jsonResponse['message'],
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['StatusDesc'],
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed with status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }*/
  Future<Map<String, dynamic>> removeShortlistedSchool({
    required String schoolId,
    required String shortListedBy,
  }) async {
    try {
      // Initialize CommonApiCall
      final commonApiCall = CommonApiCall(baseUrl: _removeSchoolUrl);
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      // Prepare the request body
      final requestPayload = {
        "serviceName": "RemoveShortedSchool",
        "schoolId": schoolId,
        "shortListedBy": userId,
      };

      // Make the API call
      final response = await commonApiCall.post(requestPayload);
      print('Decrypted response: $response');

      // Handle the response
      if (response['statusCode'] == '200') {
        return {
          'success': true,
          'message': response['message'] ?? 'School removed successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['StatusDesc'] ?? 'Failed to remove school',
        };
      }
    } catch (e) {
      print('Error: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
