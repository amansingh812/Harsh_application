import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';

class ShortlistService {
  final String _baseUrl =
      '${ApiEndpoints.baseUrl3}ShortList'; // Replace with your API URL

  /*Future<Map<String, dynamic>> shortlistData(String schoolId,
      String schoolName,
      String pinCode,
      String areaName,
      String state,
      String district,
      String city,
      String mobileNumber) async {
    final url = Uri.parse(_baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "serviceName": "addToList",
          "schoolId": schoolId,
          "schoolName": schoolName,
          "pincode": pinCode,
          "location": areaName,
          "state": state,
          "district": district,
          "city": city,
          "shortListedBy": mobileNumber
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Check if the API returned success
        if (jsonResponse['statusCode'] == '200') {
          return {'success': true, 'message': jsonResponse['statusDesc']};
        } else {
          return {'success': false, 'message': jsonResponse['statusDesc']};
        }
      } else {
        return {
          'success': false,
          'message': 'Failed with status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }*/
  Future<Map<String, dynamic>> shortlistData(
      String schoolId,
      String schoolName,
      String pinCode,
      String areaName,
      String state,
      String district,
      String city,
      String mobileNumber) async {
    final url = Uri.parse(_baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "serviceName": "addToList",
          "schoolId": schoolId,
          "schoolName": schoolName,
          "pincode": pinCode,
          "location": areaName,
          "state": state,
          "district": district,
          "city": city,
          "shortListedBy": mobileNumber
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Check if the API returned success
        if (jsonResponse['statusCode'] == '200') {
          return {'success': true, 'message': jsonResponse['statusDesc']};
        } else {
          return {'success': false, 'message': jsonResponse['statusDesc']};
        }
      } else {
        return {
          'success': false,
          'message': 'Failed with status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
