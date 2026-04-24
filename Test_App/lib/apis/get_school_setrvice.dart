import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_scout/global/global_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';
import '../constants/common_api_call.dart';
import 'api_service.dart';

class GetSchoolService {
  final String _baseUrl = '${ApiEndpoints.baseUrl3}All-S';


  Future<List<Shortlist>> fetchShortlist(String schoolId) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    try {
      // Initialize CommonApiCall with base URL
      final commonApiCall = CommonApiCall(
        baseUrl: _baseUrl, // Make sure _baseUrl is properly set
      );

      // Define the request payload
      final requestPayload = {
        "serviceName": "searchschoolById",
        "schoolId": schoolId,
        "userId": userId,
      };

      // Call the API using CommonApiCall
      final response = await commonApiCall.post(requestPayload);

      print('Decrypted response: $response');

      // Check if the response contains the required key
      if (response.containsKey('schooldetailslist')) {
        List<dynamic> resp = response['schooldetailslist'];

        if (resp is List) {
          // Parse the response into a list of Shortlist objects
          List<Shortlist> shortListed =
              resp.map((e) => Shortlist.fromJson(e)).toList();

          // ✅ Inject response-level fields (reviewsList, ratings, views)
          final totalViewCount = (response['totalViewCount'] ?? '').toString();
          final avgRating = (response['averageRating'] ?? '').toString();
          final rawReviews = response['reviewsList'];
          List<dynamic> parsedReviews = [];
          if (rawReviews is List) {
            parsedReviews = rawReviews;
          } else if (rawReviews is String && rawReviews.isNotEmpty) {
            try {
              final decoded = json.decode(rawReviews);
              if (decoded is List) parsedReviews = decoded;
            } catch (_) {}
          }
          print('📦 fetchShortlist reviewsList: type=${rawReviews.runtimeType} count=${parsedReviews.length}');
          for (final s in shortListed) {
            s.totalViewCount = totalViewCount;
            s.averageRating = avgRating;
            s.reviewsList = parsedReviews;
          }

          // Store the result globally
          GlobalData().shortListed = shortListed;

          return shortListed;
        } else {
          throw Exception('schooldetailslist is not a valid list');
        }
      } else {
        throw Exception('schooldetailslist key not found in the response');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load shortlist data');
    }
  }


  Future<List<User>> fetchUserBySchoolId(String schoolId) async {
    final data = await fetchShortlist(schoolId);

    return data.map((s) => User(
      id: s.id,
      name: s.name,
      boards: s.boards,
      classesOffered: s.classesOffered,

      // 🔥 Already parsed properly
      address: s.address,
      featureFacilities: s.featureFacilities,

      galleryImages: s.galleryImages,
      galleryVideos: s.galleryVideos,

      isLiked: true, // because coming from shortlist

      logo: s.logo,
      phoneNo: s.phoneNo,
      website: s.website,
      about: s.about,
      medium: s.medium,
      ownership: s.ownership,
      timings: s.timings,
      level: s.level,
      yearOfEstablishment: s.yearOfEstablishment,
      views: s.views,
      studentTeacherRatio: s.studentTeacherRatio,
      feeAvailableSessValues: s.feeAvailableSessValues,

      // 🛡️ Fields not needed in shortlist → keep empty safely
      slug: s.slug,
      email: s.email,
      languagesTaught: s.languagesTaught,
      dayWiseSchedule: s.dayWiseSchedule,
      verifiedBySchool: s.verifiedBySchool,
      builtInArea: s.builtInArea,
      coedStatus: s.coedStatus,
      academicSession: s.academicSession,
      numberOfStudents: s.numberOfStudents,
      brochure: s.brochure,
      myUnknownColumn: s.myUnknownColumn,
      boardsSlug: s.boardsSlug,
      format: s.format,
      scholarshipProgram: s.scholarshipProgram,
      dayScholarsAllowed: s.dayScholarsAllowed,
      faqs: s.faqs,
      schoolName: s.schoolName,
      schoolResults: s.schoolResults,
      shortName: s.shortName,
      virtualTour: s.virtualTour,
      feesStructure: s.feesStructure,
      admissions: s.admissions,
      rating: s.rating,
      showFees: s.showFees,
      addmissionEnabled: s.addmissionEnabled,
      partner: s.partner,
      verified: s.verified,
      totalViewCount: s.totalViewCount,
      averageRating: s.averageRating,
      reviewsList: s.reviewsList
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    )).toList();
  }

}

class Shortlist {
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
  List<dynamic> reviewsList;

  Shortlist({
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

  factory Shortlist.fromJson(Map<String, dynamic> jsonData) {
    List<FeatureFacility> facilities =
    FeatureFacility.fromJsonString(jsonData['featureFacilities']);



    Address address = Address.fromJson(jsonData['address']);

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

    return Shortlist(
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
      id: jsonData['id'] ?? '',
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
      phoneNo: jsonData['phoneNo'] ?? '',
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

