import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:school_scout/global/global_data.dart';
import 'package:school_scout/hive/mappers/user_to_hive_mapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';
import '../hive/models/user_hive.dart';
import '../models/mini_school_model.dart';

class ApiService {
  final String baseUrl = '${ApiEndpoints.baseUrl3}All-S';

  /*Future<List<User>> fetchUser() async {
    var pincode =
        GlobalData().pincode.isNotEmpty ? GlobalData().pincode : '560036';
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {"pinCode": '560036', "serviceName": "getSchoolDetails"}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('schooldetailslist')) {
          // Parse the respVal string into a JSON object
          List<dynamic> resp = jsonResponse['schooldetailslist'];
          List<User> users = resp.map((e) => User.fromJson(e)).toList();

          // Store users globally
          GlobalData().users = users;
          return users;
        } else {
          throw Exception('schooldetailslist key not found in the response');
        }
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load users');
    }
  }*/

  /*Future<List<User>> fetchUser(String pinCode) async {
    */ /*   var pincode =
        GlobalData().pincode.isNotEmpty ? GlobalData().pincode : '560036';*/ /*

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body:
            jsonEncode({"pinCode": pinCode, "serviceName": "getSchoolDetails"}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Decode the response body
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if the key exists
        if (jsonResponse.containsKey('schooldetailslist')) {
          // Ensure the key's value is a list
          List<dynamic> resp = jsonResponse['schooldetailslist'];
          if (resp is List) {
            // Parse the list into User objects
            List<User> users = resp.map((e) => User.fromJson(e)).toList();

            // Store users globally
            GlobalData().users = users;
            return users;
          } else {
            throw Exception('schooldetailslist is not a valid list');
          }
        } else {
          throw Exception('schooldetailslist key not found in the response');
        }
      } else {
        throw Exception(
            'Failed to fetch data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load users');
    }
  }*/
  Future<List<User>> fetchUser(String pinCode) async {
    final box = Hive.box<UserHive>('schools');
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    try {
      // Initialize CommonApiCall with base URL and encryption key
      final commonApiCall = CommonApiCall(
        baseUrl: baseUrl, // Replace with your base URL
      );

      // Define the request payload
      final requestPayload = {
        "filterSchoolsBy": pinCode /*'560064'*/,
        "serviceName": ApiEndpoints.schoolDetails,
        "userId": userId,
      };

      // Call the API using CommonApiCall
      final response = await commonApiCall.post(requestPayload);

      print('Decrypted response: $response');

      // Check if the response contains the required key
      if (response.containsKey('schooldetailslist')) {
        // Ensure the key's value is a list
        List<dynamic> resp = response['schooldetailslist'];
        if (resp is List) {
          // Parse the list into User objects
          List<User> users = resp.map((e) => User.fromJson(e)).toList();

          // Inject response-level fields
          final totalViewCount = (response['totalViewCount'] ?? '').toString();
          final avgRating = (response['averageRating'] ?? '').toString();

          // reviewsList can arrive as a real List OR as a JSON-encoded String
          List<Map<String, dynamic>> reviewsList = [];
          final rawReviews = response['reviewsList'];
          print('📦 reviewsList raw type: ${rawReviews.runtimeType} | value: $rawReviews');
          if (rawReviews is List) {
            reviewsList = rawReviews
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          } else if (rawReviews is String && rawReviews.isNotEmpty) {
            try {
              final decoded = json.decode(rawReviews);
              if (decoded is List) {
                reviewsList = decoded
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList();
              }
            } catch (e) {
              print('❌ Error parsing reviewsList string: $e');
            }
          }
          print('📦 reviewsList parsed count: ${reviewsList.length}');

          for (final user in users) {
            user.totalViewCount = totalViewCount;
            user.averageRating = avgRating;
            user.reviewsList = reviewsList;
          }

          // Extract dashboard response-level lists
          if (response['mostShortedSchools'] is List) {
            GlobalData().mostShortedSchools =
                (response['mostShortedSchools'] as List)
                    .map((e) => MiniSchool.fromJson(e as Map<String, dynamic>))
                    .toList();
          }
          if (response['yourRecentSearchedSchools'] is List) {
            GlobalData().recentSearchedSchools =
                (response['yourRecentSearchedSchools'] as List)
                    .map((e) => MiniSchool.fromJson(e as Map<String, dynamic>))
                    .toList();
          }

          // convert + save
          for (final user in users) {
            box.put(user.id, user.toHive());
          }
          // Store users globally
          GlobalData().users = users;
          GlobalData().buildThumbnailCache(users);

          return users;
        } else {
          throw Exception('schooldetailslist is not a valid list');
        }
      } else {
        throw Exception('schooldetailslist key not found in the response');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load users');
    }
  }
}

class User {
  final String level;
  bool isLiked;
  final String name;
  final String slug;
  final String email;
  final List<String> languagesTaught;
  final String dayWiseSchedule;
  final String about;
  final String boards;
  final String medium;
  final String verifiedBySchool;
  final String timings;
  final String logo;
  final String builtInArea;
  final String yearOfEstablishment;
  final String coedStatus;
  final String id;
  final String academicSession;
  final String views;
  final String numberOfStudents;
  final String website;
  final String brochure;
  final String myUnknownColumn;
  final String boardsSlug;
  final String format;
  final String scholarshipProgram;
  final String dayScholarsAllowed;
  final String classesOffered;
  final String faqs;
  final String ownership;
  final String schoolName;
  final String schoolResults;
  final String shortName;

  final String phoneNo;
  final String studentTeacherRatio;
  final String feeAvailableSessValues;
  final List<FeatureFacility> featureFacilities;
  final Address address;
  final List<String> galleryImages;
  final List<String> galleryVideos;
  final String virtualTour;

  // New fields
  final Map<String, dynamic> feesStructure;
  final Map<String, dynamic> admissions;
  final String rating;
  final String showFees;
  final String addmissionEnabled;
  final String partner;
  final String verified;
  String totalViewCount;
  String averageRating;
  List<Map<String, dynamic>> reviewsList;

  User({
    this.isLiked = false,
    required this.level,
    required this.name,
    required this.slug,
    required this.email,
    required this.languagesTaught,
    required this.dayWiseSchedule,
    required this.about,
    required this.boards,
    required this.medium,
    required this.verifiedBySchool,
    required this.timings,
    required this.logo,
    required this.builtInArea,
    required this.yearOfEstablishment,
    required this.coedStatus,
    required this.id,
    required this.academicSession,
    required this.views,
    required this.numberOfStudents,
    required this.website,
    required this.brochure,
    required this.myUnknownColumn,
    required this.boardsSlug,
    required this.format,
    required this.scholarshipProgram,
    required this.dayScholarsAllowed,
    required this.classesOffered,
    required this.faqs,
    required this.ownership,
    required this.schoolName,
    required this.schoolResults,
    required this.shortName,
    required this.phoneNo,
    required this.studentTeacherRatio,
    required this.feeAvailableSessValues,
    required this.featureFacilities,
    required this.address,
    required this.galleryImages,
    required this.galleryVideos,
    required this.virtualTour,
    this.feesStructure = const {},
    this.admissions = const {},
    this.rating = '',
    this.showFees = 'N',
    this.addmissionEnabled = 'N',
    this.partner = 'N',
    this.verified = 'N',
    this.totalViewCount = '',
    this.averageRating = '',
    this.reviewsList = const [],
  });

  static Map<String, dynamic> _parseJsonMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = json.decode(value);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return {};
  }

  factory User.fromJson(Map<String, dynamic> jsonData) {
    List<FeatureFacility> facilities =
        FeatureFacility.fromJsonString(jsonData['featureFacilities']);

    /* var addressJson = json.decode(jsonData['address']) as Map<String, dynamic>;
    Address address = Address.fromJson(addressJson);*/

    Address address = Address.fromJson(jsonData['address']);

    // Parse gallery data

    /*   Map<String, dynamic> galleryData = json.decode(jsonData['gallery']);
    List<String> images = List<String>.from(galleryData['images']);

    List<String> videos = List<String>.from(galleryData['videos']);
    String virtualTour = galleryData['virtual_tour'] ?? '';*/
    /* List<String> images = [];
    List<String> videos = [];
    String virtualTour = '';

    if (jsonData['gallery'] != null) {
      try {
        dynamic galleryData = jsonData['gallery'];

        if (galleryData is String) {
          // If gallery is a stringified JSON
          String correctedGallery = galleryData.replaceAll("'", '"');
          galleryData = json.decode(correctedGallery);
        }

        if (galleryData is Map<String, dynamic>) {
          images = List<String>.from(galleryData['images'] ?? []);
          videos = List<String>.from(galleryData['videos'] ?? []);
          virtualTour = galleryData['virtual_tour'] ?? '';
        }
      } catch (e) {
        print('Error parsing gallery: $e');
      }
    }*/

    List<String> images = [];
    List<String> videos = [];
    String virtualTour = '';

    if (jsonData['gallery'] != null) {
      try {
        dynamic galleryData = jsonData['gallery'];

        if (galleryData is String) {
          // ✅ If gallery is a string, fix formatting issues
          String correctedGallery = galleryData.replaceAll("'", '"');
          galleryData = json.decode(correctedGallery);
        }

        if (galleryData is Map<String, dynamic>) {
          // ✅ Extract images safely
          images = List<String>.from(galleryData['images'] ?? []);

          // ✅ Extract videos safely (Only `src` values from video objects)
          videos = (galleryData['videos'] as List<dynamic>?)
                  ?.where((video) =>
                      video is Map<String, dynamic> && video.containsKey('src'))
                  .map((video) => video['src'] as String)
                  .toList() ??
              [];

          // ✅ Extract virtual tour safely
          virtualTour = galleryData['virtual_tour'] is String
              ? galleryData['virtual_tour']
              : '';

          // ✅ Debug Output
          print("Images: $images");
          print("Videos: $videos");
          print("Virtual Tour: $virtualTour");
        }
      } catch (e) {
        print('Error parsing gallery: $e');
      }
    }

    return User(
      level: jsonData['level'] ?? '',
      name: jsonData['name'] ?? '',
      slug: jsonData['slug'] ?? '',
      email: jsonData['email'] ?? '',
      languagesTaught: _parseLanguagesToList(jsonData['languagesTaught']),
      // Fallback for other types


      dayWiseSchedule: jsonData['dayWiseSchedule'] ?? '',
      about: jsonData['about'] ?? '',
      boards: (jsonData['boards'] != null)
          ? (json.decode(jsonData['boards']) as List<dynamic>)
          .join(', ') // Decodes the JSON array and joins elements with a comma
          : '',

      medium: jsonData['medium'] ?? '',
      verifiedBySchool: jsonData['verifiedBySchool'] ?? '',
      timings: jsonData['timings'] ?? '',
      logo: jsonData['logo'] ?? '',
      builtInArea: jsonData['builtInArea'] ?? '',
      yearOfEstablishment: jsonData['yearOfEstablishment'] == null
          ? ''
          : (num.tryParse(jsonData['yearOfEstablishment'].toString())?.toInt().toString() ?? jsonData['yearOfEstablishment'].toString()),

      coedStatus: jsonData['coedStatus'] ?? '',
      id: (jsonData['id'] ?? '').toString(),
      academicSession: jsonData['academicSession'] ?? '',
      views: jsonData['views'] ?? '',
      numberOfStudents: jsonData['numberOfStudents'] ?? '',
      website: jsonData['website'] ?? '',
      brochure: jsonData['brochure'] ?? '',
      myUnknownColumn: jsonData['myUnknownColumn'] ?? '',
      boardsSlug: jsonData['boardsSlug'] ?? '',
      format: jsonData['format'] ?? '',
      scholarshipProgram: jsonData['scholarshipProgram'] ?? '',
      dayScholarsAllowed: jsonData['dayScholarsAllowed'] ?? '',
      classesOffered: jsonData['classesOffered'] ?? '',
      faqs: jsonData['faqs'] ?? '',
      ownership: jsonData['ownership'] ?? '',
      schoolName: jsonData['schoolName'] ?? '',
      schoolResults: jsonData['schoolResults'] ?? '',
      shortName: jsonData['shortName'] ?? '',
      phoneNo: _parsePhone(jsonData['phoneNo']),

      studentTeacherRatio: jsonData['studentTeacherRatio'] ?? '',
      feeAvailableSessValues: jsonData['feeAvailableSessValues'] ?? '',
      featureFacilities: facilities,
      address: address,
      galleryImages: images,
      galleryVideos: videos,
      virtualTour: virtualTour,
      feesStructure: _parseJsonMap(jsonData['feesStructure']),
      admissions: _parseJsonMap(jsonData['admissions']),
      rating: jsonData['rating']?.toString() ?? '',
      showFees: jsonData['showFees']?.toString() ?? 'N',
      addmissionEnabled: jsonData['addmissionEnabled']?.toString() ?? 'N',
      partner: jsonData['partner']?.toString() ?? 'N',
      verified: jsonData['verified']?.toString() ?? 'N',
    );
  }

}
String _parsePhone(dynamic value) {
  if (value == null) return '';

  if (value is int) return value.toString();

  if (value is double) {
    return value.toInt().toString(); // removes .0
  }

  String str = value.toString();

  // If backend sends "9164266003.0"
  if (str.endsWith('.0')) {
    return str.replaceAll('.0', '');
  }

  return str;
}

// Add this helper function inside your User.fromJson factory
List<String> _parseLanguagesToList(dynamic langData) {
  if (langData == null) {
    return []; // Return an empty list if null
  }

  // Case 1: The data is already a List (e.g., ["English", "Hindi"])
  if (langData is List) {
    return langData.map((e) => e.toString()).toList();
  }

  String langStr = langData.toString();

  // Case 2: The data is a String that looks like a JSON list (e.g., "[\"English\"]")
  if (langStr.startsWith('[') && langStr.endsWith(']')) {
    try {
      List<dynamic> decodedList = json.decode(langStr);
      return decodedList.map((e) => e.toString()).toList();
    } catch (e) {
      // If decoding fails, it's a malformed string. Return it as a single-item list.
      return [langStr];
    }
  }

  // Case 3: The data is just a plain string (e.g., "English")
  return [langStr]; // Return it as a single-item list
}

// ... then comes your `return User(...)` statement


// The rest of the classes (FeatureFacility, Feature, Address, City) remain the same.
class FeatureFacility {
  final String name;
  final List<Feature> features;

  FeatureFacility({required this.name, required this.features});

  factory FeatureFacility.fromJson(Map<String, dynamic> json) {
    var featuresJson = json['features'] as List;
    List<Feature> featuresList =
        featuresJson.map((feature) => Feature.fromJson(feature)).toList();

    return FeatureFacility(
      name: json['name'],
      features: featuresList,
    );
  }

  static List<FeatureFacility> fromJsonString(String jsonString) {
    // Preprocess the string to replace single quotes with double quotes
    String correctedJsonString = jsonString
        .replaceAll("'", '"') // Replace single quotes with double quotes
        .replaceAllMapped(
          RegExp(r'"\s*:\s*(\d+(\.\d+)?)'),
          (match) => '"${match.group(1)}"',
        ); // Correct numeric values inside quotes if needed

    // Decode the corrected JSON string
    List<dynamic> decodedJson = json.decode(correctedJsonString);

    // Map the list to FeatureFacility objects
    return decodedJson
        .map((facilityJson) => FeatureFacility.fromJson(facilityJson))
        .toList();
  }
}

class Feature {
  final String icon;
  final String name;
  final String exist;

  Feature({required this.icon, required this.name, required this.exist});

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      icon: json['icon'],
      name: json['name'],
      exist: json['exist'],
    );
  }
}

class Address {
  final String area;
  final City city;
  final String state;
  final String country;
  final String pincode;
  final String address1;
  final String address2;
  final String district;
  final String latitude;
  final String areaSlug;
  final String longitude;
  final String districtSlug;
  final String explorePagePartPath;
  final String locality;

  Address({
    required this.area,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.address1,
    required this.address2,
    required this.district,
    required this.latitude,
    required this.areaSlug,
    required this.longitude,
    required this.districtSlug,
    required this.explorePagePartPath,
    required this.locality,
  });

  factory Address.fromJson(dynamic json) {
    // Declare a Map to hold the parsed JSON

    if (json is String) {
      // If it's a string, decode it
      try {
        // Preprocess to fix single quotes and decode
        /*  String correctedJsonString = json.replaceAll("'", '"');

        json = jsonDecode(correctedJsonString);*/
        String correctedJsonString = fixJsonString(json);
        json = jsonDecode(correctedJsonString);
        /*  String correctedJsonString = json
            // Step 1: Fix Single Quotes in JSON Keys & Values
            .replaceAllMapped(
                RegExp(r"(?<=\{|,)\s*'([^']+?)'\s*:"), // Fix 'key': → "key":
                (match) => '"${match[1]}":')
            .replaceAllMapped(
                RegExp(r":\s*'([^']*?)'"), // Fix 'value' → "value"
                (match) => ': "${match[1]}"')

            // Step 2: Remove Invalid Backslashes Before Double Quotes
            .replaceAllMapped(
                RegExp(r'\\+"'), // Matches \"
                (match) => '"') // Replace with a normal double quote

            // Step 3: Remove Unescaped Newlines Inside String Values
            .replaceAllMapped(
                RegExp(r'(?<=:\s*")([^"]*?)\n+([^"]*?)(?=")'),
                // Matches newlines inside values
                (match) => '${match[1]} ${match[2]}'); // Replace \n with space

// Decode JSON safely
        json = jsonDecode(correctedJsonString);*/
      } catch (e) {
        throw Exception("Failed to decode address JSON string: $e");
      }
    }

    if (json is Map<String, dynamic>) {
      return Address(
        area: json['area'] ?? '',
        city: City.fromJson(json['city'] ?? {}),
        state: json['state'] ?? '',
        country: json['country'] ?? '',
        pincode: json['pincode'] ?? '',
        address1: json['adress_1'] ?? '',
        address2: json['adress_2'] ?? '',
        district: json['district'] ?? '',
        latitude: json['latitude'] ?? '',
        areaSlug: json['area_slug'] ?? '',
        longitude: json['longitude'] ?? '',
        districtSlug: json['district_slug'] ?? '',
        explorePagePartPath: json['explore_page_part_path'] ?? '',
        locality: json['locality'] ?? '',
      );
    } else {
      // If it's neither a Map nor a String, throw an error
      throw Exception("Invalid address format: $json");
    }
  }
}
/*factory Address.fromJson(dynamic json) {
    Map<String, dynamic> addressJson;

    if (json is String) {
      try {
        // Preprocess the string
        String correctedJsonString = json
            .replaceAll("'", '"') // Replace single quotes with double quotes
            .replaceAll("None", "null"); // Replace None with null

        // Decode the corrected JSON string
        addressJson = jsonDecode(correctedJsonString);
      } catch (e) {
        throw Exception("Failed to decode address JSON string: $e");
      }
    } else if (json is Map<String, dynamic>) {
      // If it's already a Map, use it directly
      addressJson = json;
    } else {
      throw Exception("Invalid address format");
    }

    // Parse fields from the JSON object
    return Address(
      area: json['area'] ?? '',
      city: City.fromJson(json['city'] ?? {}),
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
      address1: json['adress_1'] ?? '',
      address2: json['adress_2'] ?? '',
      district: json['district'] ?? '',
      latitude: json['latitude'] ?? '',
      areaSlug: json['area_slug'] ?? '',
      longitude: json['longitude'] ?? '',
      districtSlug: json['district_slug'] ?? '',
      explorePagePartPath: json['explore_page_part_path'] ?? '',
      locality: json['locality'] ?? '',
    );
  }
}*/

class City {
  final String name;
  final String slug;

  City({
    required this.name,
    required this.slug,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

dynamic parseStringifiedJson(String jsonString) {
  try {
    // Preprocess the string to replace single quotes with double quotes
    String correctedJsonString = jsonString.replaceAll("'", '"');

    // Decode the corrected JSON string
    return jsonDecode(correctedJsonString);
  } catch (e) {
    throw Exception("Failed to parse JSON string: $e");
  }
}

/*
String fixJsonString(String jsonString) {
  // Step 1: Replace incorrect single quotes ('key': 'value') with double quotes ("key": "value")
  jsonString = jsonString.replaceAllMapped(
      RegExp(r"(?<=\{|,)\s*'([^']+)'\s*:"), (match) => '"${match[1]}":');

  jsonString = jsonString.replaceAllMapped(
      RegExp(r":\s*'([^']*)'"), (match) => ': "${match[1]}"');

  // Step 2: Escape unescaped double quotes inside values
  jsonString = jsonString.replaceAllMapped(RegExp(r'(:\s*")([^"]*?)"([^"]*?")'),
      (match) => '${match[1]}${match[2]}\\\"${match[3]}');

  return jsonString;
}
*/
String fixJsonString(String jsonString) {
  return jsonString
      // Fix single quotes in keys and values
      .replaceAllMapped(
          RegExp(r"(?<=\{|,)\s*'([^']+?)'\s*:"), (match) => '"${match[1]}":')
      .replaceAllMapped(RegExp(r":\s*'([^']*?)'"), (match) => ': "${match[1]}"')

      // Remove invalid backslashes before double quotes
      .replaceAllMapped(RegExp(r'\\+"'), (match) => '"')

      // Replace unescaped newlines inside string values with spaces
      .replaceAllMapped(RegExp(r'(?<=:\s*")([^\"]*?)\n+([^\"]*?)(?=")'),
          (match) => '${match[1]} ${match[2]}')
      // Remove all control characters (including \n, \r, \t, etc.)
      .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ')
      // Trim leading and trailing whitespace
      .trim();
}

