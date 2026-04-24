import 'dart:convert'; // for jsonEncode
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';

class ChildRegisterAPI {
  final String baseUrl = '${ApiEndpoints.baseUrl3}RegisterChild';

  // Constructor to set the base API URL

  // Function to register a child
  /*Future<http.Response> registerChild({
    required String userId,
    required String firstName,
    required String middleName,
    required String lastName,
    required String gender,
    required String admissionClass,
    required String dob, // in "dd-MM-yyyy" format
    required String hobbies, // comma-separated hobbies
    String? childPic, // optional, defaults to empty string
    String? recordId, // optional, sent only when updating
  }) async {
    // Construct the request payload as a map
    Map<String, dynamic> payload = {
      "serviceName": "childRegister",
      "userId": userId,
      "firstName": firstName,
      "middleName": middleName,
      "lastName": lastName,
      "gender": gender,
      "admissionClass": admissionClass,
      "dob": dob,
      "hobbies": hobbies,
      "childPic": childPic ?? "", // Default to empty string if not provided
    };

    // Include recordId only if it's provided (for updating)
    if (recordId != null && recordId.isNotEmpty) {
      payload["recordId"] = recordId;
    }

    // Convert the payload to a JSON string
    String jsonBody = jsonEncode(payload);

    // Set up the headers for the API request
    Map<String, String> headers = {
      "Content-Type": "application/json", // Make sure API accepts JSON format
    };

    // Send a POST request
    final response = await http.post(
      Uri.parse(baseUrl),
      // Assuming API endpoint path is `/childRegister`
      headers: headers,
      body: jsonBody,
    );

    // Handle the response (success/failure, status codes, etc.)
    if (response.statusCode == 200) {
      // Success - return the response object
      return response;
    } else {
      // Failure - throw an exception or handle error
      throw Exception('Failed to register child: ${response.body}');
    }
  }*/
  Future<Map<String, dynamic>> registerChild({
    required String userId,
    required String firstName,
    required String middleName,
    required String lastName,
    required String gender,
    required String admissionClass,
    required String dob, // in "dd-MM-yyyy" format
    required String hobbies, // comma-separated hobbies
    String? childPic, // optional
    String? recordId, // optional
  }) async {
    try {
      // Initialize CommonApiCall
      final commonApiCall = CommonApiCall(baseUrl: baseUrl);

      // Construct the payload
      Map<String, dynamic> payload = {
        "serviceName": "childRegister",
        "userId": userId,
        "firstName": firstName,
        "middleName": middleName,
        "lastName": lastName,
        "gender": gender,
        "admissionClass": admissionClass,
        "dob": dob,
        "hobbies": hobbies,
        "childPic": childPic ?? "", // Default empty if null
      };

      // Include recordId if available (for update scenario)
      if (recordId != null && recordId.isNotEmpty) {
        payload["recordId"] = recordId;
      }

      // Call the API using CommonApiCall
      final response = await commonApiCall.post(payload);
      print('Decrypted response: $response');

      if (response['statusCode'] == '200') {
        return {
          'success': true,
          'message': response['statusDesc'],
          'data': response,
        };
      } else {
        return {
          'success': false,
          'message': response['statusDesc'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      print('Error during child registration: $e');
      throw Exception('Failed to register child');
    }
  }
}
