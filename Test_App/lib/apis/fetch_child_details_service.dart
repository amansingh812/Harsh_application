import 'dart:convert'; // for jsonEncode and jsonDecode
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';

class ChildDetailsAPI {
  final String baseUrl = '${ApiEndpoints.baseUrl3}ChildDetails';

  // Constructor to set the base API URL

  // Function to get child details by userId
  /*Future<List<ChildDetails>> getChildDetails({required String userId}) async {
    // Construct the request payload
    Map<String, dynamic> payload = {
      "serviceName": "getChildDetails",
      "userId": userId,
    };

    // Convert the payload to a JSON string
    String jsonBody = jsonEncode(payload);

    // Set up the headers for the API request
    Map<String, String> headers = {
      "Content-Type": "application/json", // Make sure API accepts JSON format
    };

    // Send a POST request
    final response = await http.post(
      Uri.parse(baseUrl), // Adjust the endpoint as necessary
      headers: headers,
      body: jsonBody,
    );

    // Check for successful response
    if (response.statusCode == 200) {
      // Parse the response body
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Check if the response is successful
      if (responseBody["statusCode"] == "200") {
        // Convert the response list into a list of ChildDetails objects
        List<dynamic> childDetailsList = responseBody["ChildDetailsRes"];
        List<ChildDetails> children = childDetailsList
            .map((child) => ChildDetails.fromJson(child))
            .toList();

        return children; // Return list of children
      } else {
        throw Exception('Error: ${responseBody["statusDesc"]}');
      }
    } else {
      // Handle failure by throwing an error
      throw Exception('Failed to get child details: ${response.body}');
    }
  }*/
  Future<List<ChildDetails>> getChildDetails({required String userId}) async {
    try {
      // Initialize CommonApiCall with base URL
      final commonApiCall = CommonApiCall(
        baseUrl: '${ApiEndpoints.baseUrl3}ChildDetails',
      );

      // Define the request payload
      final requestPayload = {
        "serviceName": "getChildDetails",
        "userId": userId,
      };

      // Call the API using CommonApiCall
      final response = await commonApiCall.post(requestPayload);

      print('Decrypted response: $response');

      // Check if the response contains the required key
      if (response.containsKey('childDetailsRes')) {
        List<dynamic> resp = response['childDetailsRes'];

        if (resp is List) {
          // Parse the list into ChildDetails objects
          List<ChildDetails> children =
              resp.map((e) => ChildDetails.fromJson(e)).toList();
          return children;
        } else {
          throw Exception('ChildDetailsRes is not a valid list');
        }
      } else {
        throw Exception('ChildDetailsRes key not found in the response');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load child details');
    }
  }
}

// Model class for child details
class ChildDetails {
  final String firstName;
  final String middleName;
  final String lastName;
  final String gender;
  final String admissionClass;
  final String dob;
  final String hobbies;
  final String createdOn;
  final String recordId;

  ChildDetails({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.gender,
    required this.admissionClass,
    required this.dob,
    required this.hobbies,

    required this.createdOn,
    required this.recordId,
  });

  // Factory method to create an instance from JSON
  factory ChildDetails.fromJson(Map<String, dynamic> json) {
    return ChildDetails(
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      gender: json['gender'],
      admissionClass: json['admissionClass'],
      dob: json['dob'],
      hobbies: json['hobbies'],
      createdOn: json['createdOn'],
      recordId: json['recordId'],
    );
  }
}
