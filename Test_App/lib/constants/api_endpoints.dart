/*class ApiEndpoints {
  *//* static const baseUrl =
      'http://192.168.238.148:8084/cloudapi-0.0.1-SNAPSHOT/S-Details';

  static const baseUrl2 = 'http://192.168.238.148:8084/cloudapi-0.0.1-SNAPSHOT';*//*

  //static const ip = 'myschoolscout.in:8443';
  static const ip = '192.168.1.4:8086';
  //10 version
  static const baseUrl3 = 'http://$ip/API-Services-0.0.1-SNAPSHOT/S-Details/';
  static const baseUrl2 = 'http://$ip/API-Services-0.0.1-SNAPSHOT/';

  static const loginURl = 'http://$ip/API-Services-0.0.1-SNAPSHOT/Public/Login';
  static const registerURl = 'http://$ip/API-Services-0.0.1-SNAPSHOT/Public/Register';
  static const resetPinUrl = 'http://$ip/API-Services-0.0.1-SNAPSHOT/Public/ResetPin';
  static const updatePinURL = 'http://$ip/API-Services-0.0.1-SNAPSHOT/S-Details/UserPinChange';
  static const searchSchoolsURL = 'http://$ip/API-Services-0.0.1-SNAPSHOT/S-Details/SchoolsSearch';

  static const checkUser =
      'http://$ip/API-Services-0.0.1-SNAPSHOT/Public/UserExists';
  static const filterSchools =
      'http://$ip/API-Services-0.0.1-SNAPSHOT/S-Details/FilterSchools';

    static const schoolDetails = 'getSchoolDetails';
  static const login = 'Login ';
*//*static const schoolDetails = 'getSchoolDetails';*//*
}*/
import '../config/env.dart';


class ApiEndpoints {
  static String get ip => Env.baseIP;

  static String get baseUrl3 => '$ip/API-Services-0.0.1-SNAPSHOT/S-Details/';
  static String get baseUrl2 => '$ip/API-Services-0.0.1-SNAPSHOT/';

  static String get loginURl => '$ip/API-Services-0.0.1-SNAPSHOT/Public/Login';
  static String get registerURl => '$ip/API-Services-0.0.1-SNAPSHOT/Public/Register';
  static String get resetPinUrl => '$ip/API-Services-0.0.1-SNAPSHOT/Public/ResetPin';
  static String get updatePinURL => '$ip/API-Services-0.0.1-SNAPSHOT/S-Details/UserPinChange';
  static String get searchSchoolsURL => '$ip/API-Services-0.0.1-SNAPSHOT/S-Details/SchoolsSearch';
  static String get shortListURL => '$ip/API-Services-0.0.1-SNAPSHOT/S-Details/ShortList';
  static String get deleteUserURL => '$ip/API-Services-0.0.1-SNAPSHOT/S-Details/DeleteUserDetails';

  static String get checkUser => '$ip/API-Services-0.0.1-SNAPSHOT/Public/UserExists';
  static String get filterSchools => '$ip/API-Services-0.0.1-SNAPSHOT/S-Details/FilterSchools';
  static String get accessToken => '$ip/API-Services-0.0.1-SNAPSHOT/Public/Refresh';



  static String get reviewRatingURL => '$ip/API-Services-0.0.1-SNAPSHOT/S-Details/saveSchoolRating';

  static const schoolDetails = 'getSchoolDetails';
  static const login = 'Login ';
}
