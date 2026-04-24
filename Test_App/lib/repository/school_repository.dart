import 'package:dotted_separator/dotted_separator.dart';
import 'package:hive/hive.dart';
import 'package:school_scout/hive/mappers/user_to_hive_mapper.dart';

import '../apis/api_service.dart';
import '../hive/models/user_hive.dart';

class SchoolRepository {
  final Box<List<UserHive>> box =
  Hive.box<List<UserHive>>('schools_by_city');

  /// MAIN METHOD
  Future<List<UserHive>> getSchoolsByCity(
      String city,
      Future<List<User>> Function() apiCall,
      ) async {
    // 1️⃣ Check Hive first
    if (box.containsKey(city) && box.get(city)!.isNotEmpty) {
      debugPrint('✅ Loaded schools from Hive for $city');
      return box.get(city)!;
    }

    // 2️⃣ Else call API
    debugPrint('🌐 Fetching schools from API for $city');
    final apiUsers = await apiCall();

    // 3️⃣ Convert API → Hive
    final hiveUsers = apiUsers.map((u) => u.toHive()).toList();

    // 4️⃣ Save city-wise
    await box.put(city, hiveUsers);

    return hiveUsers;
  }

  /// Optional clear per city
  Future<void> clearCity(String city) async {
    await box.delete(city);
  }

  /// Clear all cities
  Future<void> clearAll() async {
    await box.clear();
  }
}
