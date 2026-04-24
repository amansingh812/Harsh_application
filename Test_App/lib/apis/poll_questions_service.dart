import 'package:dio/dio.dart';
import 'package:school_scout/global/global_data.dart';

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';
import '../model/poll_model.dart';

class PollService {
  final Dio _dio = Dio();
  final String baseUrl =
      '${ApiEndpoints.baseUrl3}questionsList'; // Replace with your actual API URL

  // Method to fetch poll questions
  /* Future<List<PollQuestion>> fetchPollQuestions(String userId) async {
    try {
      // Request body
      Map<String, dynamic> requestData = {
        "userId": userId,
      };

      // API call
      Response response = await _dio.post(
        '$baseUrl',
        data: requestData,
      );

      if (response.statusCode == 200 && response.data['statusCode'] == '200') {
        // Parse the poll questions
        List<PollQuestion> pollQuestions =
            (response.data['pollQuestions'] as List)
                .map((question) => PollQuestion.fromJson(question))
                .toList();

        return pollQuestions;
      } else {
        // Handle other status codes or errors
        throw Exception('Failed to fetch poll questions');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching poll questions');
    }
  }*/
  Future<List<PollQuestion>> fetchPollQuestions(String userId) async {
    try {
      // Initialize CommonApiCall with base URL
      final commonApiCall = CommonApiCall(baseUrl: baseUrl);

      // Prepare the request payload
      final requestPayload = {
        "serviceName": "fetchPollQuestions", // Add service name if required
        "userId": userId,
      };

      // Call the API using CommonApiCall
      final response = await commonApiCall.post(requestPayload);
      print('Decrypted response: $response');

      // Check if the response is successful
      if (response['statusCode'] == '200') {
        List<dynamic> questionsJson = response['pollQuestions'] ?? [];

        // Parse to List<PollQuestion>
        List<PollQuestion> pollQuestions =
            questionsJson.map((e) => PollQuestion.fromJson(e)).toList();

        return pollQuestions;
      } else {
        throw Exception(
            'Failed to fetch poll questions: ${response['statusDesc']}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching poll questions');
    }
  }
}
