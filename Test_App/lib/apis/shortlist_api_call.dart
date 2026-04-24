import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';

class ShortlistApiCall {
  final String baseUrl = ApiEndpoints.shortListURL;

  Future<bool> shortList({
    required String schoolId,
    required String schoolName,
    required String pinCode,
    required String areaName,
    required String state,
    required String district,
    required String city,
    required String mobileNumber,
  }) async {
    final commonApiCall = CommonApiCall(baseUrl: baseUrl);
    print(baseUrl);

    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    final payload = {
      "serviceName": "addToList",
      "schoolId": schoolId,
      "schoolName": schoolName,
      "pincode": pinCode,
      "location": areaName,
      "state": state,
      "district": district,
      "city": city,
      "shortListedBy": userId,
    };
    print(payload);
    final response = await commonApiCall.post(payload);
    print('Decrpypted response $response');

    if (response["statusCode"] == "200") {
      return true; // ✅ success
    }

    throw Exception(response["statusDesc"] ?? "Shortlist failed");
  }
}
