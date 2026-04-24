import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';

class UpdateUserService {
  final Dio _dio = Dio();

  // Replace with your actual base URL
  final String baseUrl = '${ApiEndpoints.baseUrl3}UpdateUserDetails';

/* Future<Map<String, dynamic>> updateUserDetails({
    required String firstName,
    required String lastName,
    required String mobNumber,
    required String appId,
    required String userId,
    required String gender,
    String userPic = '',
    String email = '',
  }) async {
    //  final String endpoint = 'UpdateUserDetails';

    try {
      print(updateUserDetails);
      final response = await _dio.post(
        '$baseUrl',
        data: {
          "serviceName": "UpdateUserDetails",
          "firstName": firstName,
          "lastName": lastName,
          "mobNumber": mobNumber,
          "appId": appId,
          "userPic": userPic,
          "userId": userId,
          "email": email,
          "gender": gender
        },
      );

      // Check if the response status is 200 and the API status is 'success'
      if (response.statusCode == 200 &&
          response.data['statusDesc'] == 'success') {
        return {"success": true, "message": response.data['statusDesc']};
      } else {
        return {
          "success": false,
          "message":
          response.data['statusDesc'] ?? 'Failed to update user details',
        };
      }
    } catch (e) {
      // Handle Dio exceptions (like network issues, server errors, etc.)
      return {
        "success": false,
        "message": 'Error: $e',
      };
    }
  }*/
  Future<Map<String, dynamic>> updateUserDetails({
    required String firstName,
    required String lastName,
    required String mobNumber,
    required String appId,
    required String userId,
    required String gender,
    String userPic = '',
    String email = '',
  }) async {
    try {
      // Initialize the common API call instance
      final commonApiCall = CommonApiCall(baseUrl: baseUrl);

      // Prepare the request payload
      final requestPayload = {
        "serviceName": "UpdateUserDetails",
        "firstName": firstName,
        "lastName": lastName,
        "mobNumber": mobNumber,
        "appId": appId,
        "userPic": userPic,
        "userId": userId,
        "email": email,
        "gender": gender,
      };

      // Send the POST request
      final response = await commonApiCall.post(requestPayload);
      print('Decrypted response: $response');

      // Check for a successful update
      if (response['statusDesc'] == 'success') {
        return {"success": true, "message": response['statusDesc']};
      } else {
        return {
          "success": false,
          "message": response['statusDesc'] ?? 'Failed to update user details',
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": 'Error: $e',
      };
    }
  }
}
