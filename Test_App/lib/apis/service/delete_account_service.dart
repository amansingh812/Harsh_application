
import '../../constants/api_endpoints.dart';
import '../../constants/common_api_call.dart';



class DeleteAccountService {
  final String _baseUrl =
      ApiEndpoints.deleteUserURL; // Replace with your API URL


  Future<Map<String, dynamic>> deleteAccount(String userId) async {
    try {
      // Initialize CommonApiCall with base URL
      final commonApiCall = CommonApiCall(
        baseUrl: _baseUrl, // Ensure this includes the correct endpoint
      );

      // Define the request payload
      final requestPayload = {

        "serviceName": "DeleteUser",
        "pin": "",
        "appId": "SID",
        "mobNumber": "",
        "appVersion": "",
        "email": "",
        "firstName": "",
        "gender": "",
        "lastName": "",
        "userId": userId,
        "userPic": "",
        "userName": "",
        "roles": "",
        "userDob": "",
        "userAppVersion": "",
        "maker": "Y",
        "checker": "N"

      };

      // Call the API using CommonApiCall
      final response = await commonApiCall.post(requestPayload);

      print('Decrypted response: $response');

      // Check if the response contains a successful status code
      if (response['statusCode'] == '200') {
        return {
          'success': true,
          'message': response['message'] ?? 'Account deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? response['statusDesc'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      print('Delete error: $e');
      return {
        'success': false,
        'message': 'Something went wrong',
      };
    }
  }
}
