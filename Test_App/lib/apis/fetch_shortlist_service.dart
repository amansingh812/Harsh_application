import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';

class FetchShortlistService {
  final String _baseUrl =
      '${ApiEndpoints.baseUrl3}ShortedSchools'; // Replace with your API URL


  Future<Map<String, dynamic>> fetchShortlistData(String mobileNumber) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    try {
      // Initialize CommonApiCall with base URL
      final commonApiCall = CommonApiCall(
        baseUrl: _baseUrl, // Ensure this includes the correct endpoint
      );

      // Define the request payload
      final requestPayload = {
        "serviceName": "ShortListed",
        "shortListedBy": userId,
      };

      // Call the API using CommonApiCall
      final response = await commonApiCall.post(requestPayload);

      print('Decrypted response: $response');

      // Check if the response contains a successful status code
      if (response['statusCode'] == '200') {
        final List<dynamic> shortedList = response['shortedList'] ?? [];

        return {
          'success': true,
          'shortedList': shortedList,
          'message': response['statusDesc'],
        };

      } else {
        return {
          'success': false,
          'message': response['statusDesc'] ?? 'Unknown error',
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
