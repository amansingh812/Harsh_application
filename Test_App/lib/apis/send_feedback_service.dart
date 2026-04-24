import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';

class SendFeedbackService {
  /*Future<Map<String, dynamic>?> sendFeedbackResponseService(
      {required String userId,
      required String questionId,
      required String schoolId}) async {
    try {
      Dio dio = Dio();
      final response = await dio.post(
        '${ApiEndpoints.baseUrl3}/reviewDetails',
        data: {
          "userId": userId,
          "questionId": questionId,
          "schoolId": schoolId
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;

        if (data['statusCode'] == '200') {
          // Returning the entire response data if needed
          return data;
        } else {
          // In case of API failure, you can return an error message or null
          print('API Error: ${data['statusDesc']}');
          return null;
        }
      } else {
        // In case of non-200 HTTP status code
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Handle Dio or other errors
      print('Error: $e');
      return null;
    }
  }*/
  Future<Map<String, dynamic>?> sendFeedbackResponseService({
    required String userId,
    required String questionId,
    required String schoolId,
  }) async {
    try {
      // Initialize CommonApiCall with base URL
      final commonApiCall = CommonApiCall(baseUrl: ApiEndpoints.baseUrl3);

      // Construct the request payload
      final requestPayload = {
        "serviceName": "reviewDetails",
        "userId": userId,
        "questionId": questionId,
        "schoolId": schoolId,
      };

      // Call the API
      final response = await commonApiCall.post(requestPayload);
      print('Decrypted response: $response');

      // Check if the API returned success
      if (response['statusCode'] == '200') {
        return response; // Return full response if needed
      } else {
        print('API Error: ${response['statusDesc']}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
