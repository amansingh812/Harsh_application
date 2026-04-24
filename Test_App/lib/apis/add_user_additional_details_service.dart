import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';

class AddUserAdditionalDetailsService {
  final String baseUrl = '${ApiEndpoints.baseUrl3}UserAdditionalDetails';

  Future<void> submitUserAdditionalDetails({
    required String userId,
    required String qualification,
    required String userCat,
    required String admissionCategory,
    required String occupation,
    required String annualIncome,
    required String sessionPeriod,
    required String state,
    required String city,
    required String locality,
    required String landmark,
    required String dob,
  }) async {
    try {
      // ✅ Initialize CommonApiCall
      final commonApiCall = CommonApiCall(
        baseUrl: baseUrl,
      );

      // ✅ Request payload
      final requestPayload = {
        "serviceName": "UserAdditionalDetails",
        "userId": userId,
        "qualification": qualification,
        "userCat": userCat,
        "addmissionCategory": admissionCategory,
        "occupation": occupation,
        "annualIncome": annualIncome,
        "sessionPeriod": sessionPeriod,
        "state": state,
        "city": city,
        "locality": locality,
        "landmark": landmark,
        "dob": dob,
      };

      // ✅ API Call
      final response = await commonApiCall.post(requestPayload);

      print('Decrypted response: $response');

      // ✅ Response handling
      if (response["statusCode"] == "200") {
        print('✅ Success: ${response["statusDesc"]}');
      } else {
        throw Exception('❌ Error: ${response["statusDesc"]}');
      }
    } catch (e) {
      print('❌ Submit User Additional Details Error: $e');
      throw Exception('Failed to submit user additional details');
    }
  }
}
