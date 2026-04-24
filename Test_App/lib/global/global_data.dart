import 'package:dotted_separator/dotted_separator.dart';
import 'package:hive/hive.dart';
import 'package:school_scout/apis/get_school_setrvice.dart';
import 'package:school_scout/hive/mappers/user_to_hive_mapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/master_api_dart.dart';
import '../apis/api_service.dart';
import '../hive/models/user_hive.dart';
import '../models/mini_school_model.dart';
import '../widgets/my_bottomNavigator.dart';

class GlobalData {
  static final GlobalData _instance = GlobalData._internal();

  factory GlobalData() {
    return _instance;
  }

  GlobalData._internal();

  // Existing fields
  static final ValueNotifier<bool> isLocationChanging =
  ValueNotifier<bool>(false);
  Box<UserHive> get schoolBox => Hive.box<UserHive>('schools');
  final ValueNotifier<int> compareCount = ValueNotifier<int>(0);


  static final ValueNotifier<bool> homeDataReady = ValueNotifier<bool>(false);
  bool cameFromShortlist = false;
  List<User> users = [];
  List<Shortlist> shortListed = [];
  List<MiniSchool> mostShortedSchools = [];
  List<MiniSchool> recentSearchedSchools = [];

  /// schoolId → first gallery image URL (populated whenever users are loaded)
  Map<String, String> schoolThumbnails = {};

  void buildThumbnailCache(List<User> users) {
    for (final u in users) {
      if (u.galleryImages.isNotEmpty) {
        schoolThumbnails[u.id.toString()] = u.galleryImages.first;
      }
    }
  }

  String city = 'Bangalore';
  String pincode = '';
  String areaName = '';
  String gender ='';

  bool isLoading = false;
  Map<String, List<String>> areasByCity = {};

  // New fields for storing different properties
  List<User> selectedSchools = [];
  List<CityData> cities = [];
  List<String> areas = [];

  List<String> occupations = [];
  List<String> qualification = [];
  List<String> role = [];
  List<String> annual_income = [];
  List<String> hobbies = [];

  List<String> boards = [];
  List<String> coEdStatus = [];
  List<String> academicSessions = [];
  List<Course> courses = [];
  List<String> languages = [];
  List<String> annualIncome = [];
  List<SchoolType> schoolTypes = [];

  List<String> states = [];
  Map<String, List<String>> citiesByState = {};
  Map<String, dynamic> activeCities = {};
  List<String> get areasForSelectedCity {
    if (city.isEmpty) return [];
    return areasByCity[city] ?? [];
  }
  // Fields for storing selected values
  String selectedSchoolType = 'Day School';
  String searchQuery = ''; // Fields for storing selected values
  // New fields for storing user details globally
  String? userId;
  String? firstName;
  String? lastName;
  String? email;
  String? mobNumber;
  String? lastLogin;
  String? appVersion;


  String? authToken;
  String? refreshToken;

  void reset() {
    authToken = '';
    mobNumber = '';
    refreshToken = '';
    city = 'Bangalore';
    pincode = '560001';
    users.clear();
    selectedSchools.clear();
    compareCount.value = 0;
  }

  // ➕ ADD school to compare
  void addToCompare(User user) {
    if (!selectedSchools.contains(user) && selectedSchools.length < 2) {
      selectedSchools.add(user);
      compareCount.value = selectedSchools.length;
    }
    else {
      GlobalData().selectedSchools.remove(user);
    }
  }
  void toggleCompare(User user) {
    if (selectedSchools.contains(user)) {
      selectedSchools.remove(user);
    } else if (selectedSchools.length < 2) {
      selectedSchools.add(user);
    }

    compareCount.value = selectedSchools.length;
  }

  // ➖ REMOVE school from compare
  void removeFromCompare(User user) {
    if (selectedSchools.contains(user)) {
      selectedSchools.remove(user);
      compareCount.value = selectedSchools.length;
    }
  }

  // 🧹 CLEAR compare (when leaving page)
  void clearCompare() {
    selectedSchools.clear();
    compareCount.value = 0;
  }


  void clear() {
    authToken = null;
   // mobNumber = null;
    userId = null;
    refreshToken = null;
  }
  // Methods to get data in required format
  List<String> getAreas() => areas;

  List<String> getHobbies() => hobbies;

  List<String> getQualification() => qualification;

  List<String> getOccupation() => occupations;

  List<String> getAnnualIncome() => annual_income;

  List<String> getLanguages() => languages;

  List<String> getRole() => role;

  List<String> getBoards() => boards;

  List<String> getCoEdStatus() => coEdStatus;

  List<String> getAcademicSession() => academicSessions;

  List<String> getCourseNames() =>
      courses.map((course) => course.name).toList();

  /*List<String> getLanguageNames() =>
      languages.map((language) => language.name).toList();*/

  List<String> getSchoolTypeNames() =>
      schoolTypes.map((schoolType) => schoolType.name).toList();

  // Methods to update selected values
  void updateSelectedSchoolType(String value) {
    if (value.isNotEmpty) {
      selectedSchoolType = value;
    } else {
      selectedSchoolType = 'Day School';
    }
  }

  void updateSearchQuery(String value) {
    searchQuery = value;
  }

  // Method to store data from the API
  void storeMasterData({
    required List<CityData> cities,
    required List<String> areas,
    required List<String> boards,
    required List<String> coEdStatus,
    required List<SchoolType> schoolTypes,
    required List<String> academicSessions,
    required List<Course> courses,
    required List<String> languages,
    required List<String> occupations,
    required List<String> qualification,
    required List<String> role,
    required List<String> annual_income,
    required List<String> hobbies,
  }) {
    this.cities = cities;
    this.areas = areas;
    this.boards = boards;
    this.coEdStatus = coEdStatus;
    this.schoolTypes = schoolTypes;
    this.academicSessions = academicSessions;
    this.courses = courses;
    this.languages = languages;
    this.occupations = occupations;
    this.qualification = qualification;
    this.role = role;
    this.annual_income = annual_income;
    this.hobbies = hobbies;
  }

  // Method to store user details globally after login
  void storeUserDetails({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String mobNumber,
    required String lastLogin,
    required String appVersion,
    required String authToken,
    required String refreshToken,
  }) {
    this.userId = userId;
    this.firstName = firstName;
    this.lastName = lastName;
    this.email = email;
    this.mobNumber = mobNumber;
    this.lastLogin = lastLogin;
    this.appVersion = appVersion;
    this.authToken = authToken;
    this.refreshToken = refreshToken;
  }

  // Method to clear user details on logout or session expiry
  void clearUserDetails() {
    userId = null;
    firstName = null;
    lastName = null;
    email = null;
    mobNumber = null;
    lastLogin = null;
    appVersion = null;
    authToken = null;
    refreshToken = null;
  }
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  Future<void> changeLocation({
    required String city,
    required String pincode,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // 🔄 START LOADER
      isLocationChanging.value = true;

      // 1️⃣ Save location permanently
      await prefs.setString('city', city);
      await prefs.setString('pincode', pincode);

      this.city = city;
      this.pincode = pincode;

      // 2️⃣ CLEAR MEMORY
      users.clear();
      selectedSchools.clear();

      // 3️⃣ CLEAR HIVE SAFELY (only old data)
      final box = Hive.box<UserHive>('schools');
      await box.clear();

      // 4️⃣ FETCH FRESH DATA
      final api = ApiService();
      final freshUsers = await api.fetchUser(pincode);

      users = freshUsers;
      buildThumbnailCache(freshUsers);

      // 5️⃣ SAVE TO HIVE
      for (final u in freshUsers) {
        await box.put('${city}_${pincode}_${u.id}', u.toHive());
      }

      // 6️⃣ NOTIFY APP
      homeDataReady.value = false;
      homeDataReady.value = true;
    } catch (e) {
      debugPrint('❌ changeLocation failed: $e');
    } finally {
      // 🛑 STOP LOADER
      isLocationChanging.value = false;
    }
  }


}

// Definitions of the data classes
/*class AcademicSession {
  final String sessionName;

  AcademicSession(this.sessionName);

  @override
  String toString() => sessionName;
}*/

class Course {
  final String id;
  final String name;
  final String slug;

  Course({required this.id, required this.name, required this.slug});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      name: json['name'],
      slug: json['slug'],
    );
  }

  @override
  String toString() => name;
}

class SchoolType {
  final String id;
  final String name;
  final String slug;

  SchoolType({required this.id, required this.name, required this.slug});

  factory SchoolType.fromJson(Map<String, dynamic> json) {
    return SchoolType(
      id: json['id'].toString(),
      name: json['name'],
      slug: json['slug'],
    );
  }

  @override
  String toString() => name;
}

class Language {
  final String name;

  Language(this.name);

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(json['language']);
  }

  @override
  String toString() => name;
}


// Assuming CityData and SchoolType classes are defined as:
