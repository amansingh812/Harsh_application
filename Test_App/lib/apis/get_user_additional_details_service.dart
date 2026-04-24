import 'dart:convert'; // for jsonEncode and jsonDecode
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';

class UserAdditionalDetailsAPI {
  final String baseUrl = '${ApiEndpoints.baseUrl3}getUserAdditionalDetails';

  // Constructor to set the base API URL

  // Function to fetch user additional details
  /*Future<Map<String, dynamic>?> getUserAdditionalDetails(
      {required String userId}) async {
    // Construct the request payload
    Map<String, dynamic> payload = {
      "serviceName": "getUserAdditionalDetails",
      "userId": userId,
    };

    // Convert the payload to a JSON string
    String jsonBody = jsonEncode(payload);

    // Set up the headers for the API request
    Map<String, String> headers = {
      "Content-Type": "application/json", // Ensure API accepts JSON format
    };

    // Send a POST request
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonBody,
    );

    // Check for a successful response
    if (response.statusCode == 200) {
      // Parse the response body
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Check if the response is successful
      if (responseBody["statusCode"] == "200") {
        print('Success: ${responseBody["statusDesc"]}');

        // Extract the user additional details
        List<dynamic> userAdditionalDetails = responseBody["userAdditionalRes"];

        if (userAdditionalDetails.isNotEmpty) {
          return userAdditionalDetails.first; // Return the first user's details
        } else {
          print('No additional details found.');
          return null; // Handle if the response is empty
        }
      } else {
        throw Exception('Error: ${responseBody["statusDesc"]}');
      }
    } else {
      // Handle failure by throwing an error
      throw Exception(
          'Failed to fetch user additional details: ${response.body}');
    }
  }*/
  Future<Map<String, dynamic>?> getUserAdditionalDetails(
      {required String userId}) async {
    try {
      // Initialize CommonApiCall with base URL
      final commonApiCall = CommonApiCall(
        baseUrl: baseUrl, // Ensure this is the correct endpoint
      );

      // Define the request payload
      final requestPayload = {
        "serviceName": "getUserAdditionalDetails",
        "userId": userId,
      };

      // Call the API using CommonApiCall
      final response = await commonApiCall.post(requestPayload);

      print('Decrypted response: $response');

      // Check if the response is successful
      if (response["statusCode"] == "200") {
        print('Success: ${response["statusDesc"]}');

        // Extract user additional details
        List<dynamic> userAdditionalDetails =
            response["userAdditionalRes"] ?? [];

        if (userAdditionalDetails.isNotEmpty) {
          return userAdditionalDetails.first; // Return first user's details
        } else {
          print('No additional details found.');
          return null;
        }
      } else {
        throw Exception('Error: ${response["statusDesc"]}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch user additional details');
    }
  }
}
