import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';

class FeedbackService {
  final Dio _dio = Dio();

  // Function to send feedback
  Future<Map<String, dynamic>> sendFeedback(
      {required String userId,
      required String questionId,
      required String schoolId,
      required String feedbackText}) async {
    String url =
        '${ApiEndpoints.baseUrl3}recordUserFeedback'; // Replace with your actual API URL

    // Request payload
    Map<String, dynamic> data = {
      "userId": userId,
      "questionId": questionId,
      "schoolId": schoolId,
      "feedbackText": feedbackText,
    };

    try {
      // Make the POST request
      Response response = await _dio.post(
        url,
        data: data,
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Return the response data
        return response.data;
      } else {
        throw Exception("Failed to send feedback");
      }
    } catch (e) {
      throw Exception("Error occurred: $e");
    }
  }
}
