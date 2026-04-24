import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';
import '../global/global_data.dart';

class MasterApi {
  final String baseUrl = '${ApiEndpoints.baseUrl3}MasterData';

  /*Future<void> fetchMaster() async {
    try {
      final commonApiCall = CommonApiCall(baseUrl: baseUrl);

      // Define the request payload
      final requestPayload = {
        "serviceName": "AllMasterData",
      };

      // Call the API
      final response = await commonApiCall.post(requestPayload);
      print('Decrypted response: $response');
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('masterDetailsList')) {
          List<dynamic> masterDetailsList = jsonResponse['masterDetailsList'];

          for (var masterDetail in masterDetailsList) {
            String propertyName = masterDetail['propetyName'];
            String propVal = masterDetail['propVal'];

            switch (propertyName) {
              case 'CITY':
                List<dynamic> citiesJson = json.decode(propVal);
                GlobalData().cities = citiesJson
                    .map((cityJson) => CityData.fromJson(cityJson))
                    .toList();
                print(GlobalData().cities);
                break;

              case 'BLR_LOCALITES':
                Map<String, dynamic> localitiesMap = json.decode(propVal);
                List<dynamic> localitiesJson =
                    localitiesMap['Bangalore_Localities'];
                GlobalData().localities = List<String>.from(localitiesJson);
                break;

              case 'OCCUPATION':
                Map<String, dynamic> occupationsMap = json.decode(propVal);
                List<dynamic> occupationsJson = occupationsMap['occupations'];
                GlobalData().occupations = List<String>.from(occupationsJson);
                print((GlobalData().occupations));
                break;

              case 'QUALIFICATION':
                Map<String, dynamic> qualificationMap = json.decode(propVal);
                List<dynamic> qualificationJson =
                    qualificationMap['qualification'];
                GlobalData().qualification =
                    List<String>.from(qualificationJson);
                print((GlobalData().qualification));
                break;

              case 'HOBBIES':
                Map<String, dynamic> hobbiesMap = json.decode(propVal);
                List<dynamic> hobbiesJson = hobbiesMap['hobbies'];
                GlobalData().hobbies = List<String>.from(hobbiesJson);
                print((GlobalData().hobbies));
                break;

              case 'ROLE':
                Map<String, dynamic> roleMap = json.decode(propVal);
                List<dynamic> roleJson = roleMap['role'];
                GlobalData().role = List<String>.from(roleJson);
                print((GlobalData().role));
                break;

              case 'ANNUAL_INCOME':
                Map<String, dynamic> annualIncomeMap = json.decode(propVal);
                List<dynamic> annualIncomeJson =
                    annualIncomeMap['annual_income'];
                GlobalData().annual_income =
                    List<String>.from(annualIncomeJson);
                break;

              case 'BOARD':
                Map<String, dynamic> boardsMap = json.decode(propVal);
                List<dynamic> boardsJson = boardsMap['boardS'];
                GlobalData().boards = List<String>.from(boardsJson);
                break;

              case 'CO_ED_STATUS':
                Map<String, dynamic> coedMap = json.decode(propVal);
                List<dynamic> coEdStatusJson = coedMap['CoEd_Status'];
                GlobalData().coEdStatus = List<String>.from(coEdStatusJson);
                break;

              case 'ACADEMIC_SESSION':
                Map<String, dynamic> sessionMap = json.decode(propVal);
                List<dynamic> sessionJson = sessionMap['session'];
                GlobalData().academicSessions = List<String>.from(sessionJson);
                print((GlobalData().role));
                break;

              case 'COURSES':
                List<dynamic> coursesJson = json.decode(propVal);
                GlobalData().courses = coursesJson
                    .map((courseJson) => Course.fromJson(courseJson))
                    .toList();
                break;

              case 'LANGUAGE_OF_INSTRUCTION':
                Map<String, dynamic> languageMap = json.decode(propVal);
                List<dynamic> languageJson = languageMap['language'];
                GlobalData().languages = List<String>.from(languageJson);
                print((GlobalData().languages));
                break;

              case 'TYPES_OF_SCHOOL':
                List<dynamic> schoolTypesJson = json.decode(propVal);
                GlobalData().schoolTypes = schoolTypesJson
                    .map((typeJson) => SchoolType.fromJson(typeJson))
                    .toList();
                break;

              default:
                print('Unhandled propertyName: $propertyName');
            }
          }
        } else {
          print('Response does not contain masterDetailsList');
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }*/
  Future<void> fetchMaster() async {
    try {
      // Initialize CommonApiCall with base URL
      final commonApiCall = CommonApiCall(baseUrl: baseUrl);

      // Define the request payload
      final requestPayload = {
        "serviceName": "AllMasterData",
      };

      // Call the API
      final response = await commonApiCall.post(requestPayload);
      print('Decrypted response: $response');

      // Check if masterDetailsList is available
      if (response.containsKey('masterDetailsList')) {
        List<dynamic> masterDetailsList = response['masterDetailsList'];

        for (var masterDetail in masterDetailsList) {
          String propertyName = masterDetail['propetyName'];
          String propVal = masterDetail['propVal'];

          switch (propertyName) {
            case 'CITY':
              List<dynamic> citiesJson = json.decode(propVal);
              GlobalData().cities = citiesJson
                  .map((cityJson) => CityData.fromJson(cityJson))
                  .toList();
              print(GlobalData().cities);
              break;

            case 'AREAS':
              final Map<String, dynamic> areasMap = parsePropVal(propVal);
              GlobalData().areas = safeList(areasMap['Bangalore']);
              break;

            case 'BOARD':
              final Map<String, dynamic> boardsMap = parsePropVal(propVal);
              GlobalData().boards = safeList(boardsMap['boards']);
              break;

            case 'OCCUPATION':
              Map<String, dynamic> occupationsMap = json.decode(propVal);
              List<dynamic> occupationsJson = occupationsMap['occupations'];
              GlobalData().occupations = List<String>.from(occupationsJson);
              print(GlobalData().occupations);
              break;

            case 'QUALIFICATION':
              Map<String, dynamic> qualificationMap = json.decode(propVal);
              List<dynamic> qualificationJson =
              qualificationMap['qualification'];
              GlobalData().qualification = List<String>.from(qualificationJson);
              print(GlobalData().qualification);
              break;

            case 'HOBBIES':
              Map<String, dynamic> hobbiesMap = json.decode(propVal);
              List<dynamic> hobbiesJson = hobbiesMap['hobbies'];
              GlobalData().hobbies = List<String>.from(hobbiesJson);
              print(GlobalData().hobbies);
              break;

            case 'ROLE':
              Map<String, dynamic> roleMap = json.decode(propVal);
              List<dynamic> roleJson = roleMap['role'];
              GlobalData().role = List<String>.from(roleJson);
              print(GlobalData().role);
              break;

            case 'ANNUAL_INCOME':
              Map<String, dynamic> annualIncomeMap = json.decode(propVal);
              List<dynamic> annualIncomeJson = annualIncomeMap['annual_income'];
              GlobalData().annual_income = List<String>.from(annualIncomeJson);
              break;


            case 'CO_ED_STATUS':
              Map<String, dynamic> coedMap = parsePropVal(propVal);
              List<dynamic> coEdStatusJson = coedMap['CoEd_Status'];
              GlobalData().coEdStatus = List<String>.from(coEdStatusJson);
              break;

            case 'ACADEMIC_SESSION':
              Map<String, dynamic> sessionMap = json.decode(propVal);
              List<dynamic> sessionJson = sessionMap['session'];
              GlobalData().academicSessions = List<String>.from(sessionJson);
              break;

            case 'COURSES':
              List<dynamic> coursesJson = json.decode(propVal);
              GlobalData().courses = coursesJson
                  .map((courseJson) => Course.fromJson(courseJson))
                  .toList();
              break;

            case 'LANGUAGE_OF_INSTRUCTION':
              Map<String, dynamic> languageMap = parsePropVal(propVal);
              List<dynamic> languageJson = languageMap['language'];
              GlobalData().languages = List<String>.from(languageJson);
              print(GlobalData().languages);
              break;

            case 'TYPES_OF_SCHOOL':
              List<dynamic> schoolTypesJson = json.decode(propVal);
              GlobalData().schoolTypes = schoolTypesJson
                  .map((typeJson) => SchoolType.fromJson(typeJson))
                  .toList();
              break;

            default:
              print('Unhandled propertyName: $propertyName');
          }
        }
      } else {
        print('Response does not contain masterDetailsList');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }
}

class CityData {
  final String name;
  final String pincode;

  CityData({required this.name, required this.pincode});

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      name: json['name'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }
}

class AcademicSession {
  final String sessionName;

  AcademicSession({required this.sessionName});

  factory AcademicSession.fromJson(Map<String, dynamic> json) {
    return AcademicSession(
      sessionName: json['sessionName'] ?? '',
    );
  }
}
dynamic parsePropVal(String propVal) {
  // Remove starting & ending single quotes if present
  if (propVal.startsWith("'") && propVal.endsWith("'")) {
    propVal = propVal.substring(1, propVal.length - 1);
  }
  return json.decode(propVal);
}

List<String> safeList(dynamic value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return [];
}
