import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_separator/dotted_separator.dart';
import '../../global/global_data.dart';
import 'master_cache_service.dart';

class MasterSyncService {
  static Future<void> sync() async {
    final localVersion = MasterCacheService.version ?? 0;


    final versionDoc = await FirebaseFirestore.instance
        .collection('masterData')
        .doc('MASTER_VERSION')
        .get();

      int remoteVersion = 1; // default

    if (versionDoc.exists && versionDoc.data() != null) {
      remoteVersion = versionDoc.data()!['version'] ?? 1;
    }

    if (remoteVersion <= localVersion && MasterCacheService.data != null) {
      debugPrint('💾 Master loaded from HIVE');
      _loadFromMap(MasterCacheService.data!);
      return;
    }


    debugPrint('🌐 Master fetched from FIRESTORE');


    // 🔄 Fetch fresh
    final snapshot =
    await FirebaseFirestore.instance.collection('masterData').get();

    final Map<String, dynamic> masterMap = {};

    for (final doc in snapshot.docs) {
      if (doc.id != 'MASTER_VERSION') {
        masterMap[doc.id] = doc['data'];
      }
    }

    MasterCacheService.saveData(masterMap);
    MasterCacheService.saveVersion(remoteVersion);

    _loadFromMap(masterMap);
  }

  static void _loadFromMap(Map<String, dynamic> master) {
    // ===== AREAS =====
    // ===== AREAS (🔥 FIXED FOR NEW STRUCTURE) =====
    if (master.containsKey('AREAS')) {
      final data = master['AREAS'];

      if (data is Map<String, dynamic>) {
        print("City ${GlobalData().areasByCity}");
        GlobalData().areasByCity = data.map(
              (city, areas) => MapEntry(
            city,
            List<String>.from(areas),
          ),
        );
      }
    }


    // ===== BOARDS =====
    if (master.containsKey('BOARD')) {
      final list = master['BOARD'] as List;
      GlobalData().boards =
          list.map((e) => e['boards']).expand((e) => List<String>.from(e)).toList();
    }

    // ===== CO-ED =====
    if (master.containsKey('CO_ED_STATUS')) {
      final raw = Map<String, dynamic>.from(master['CO_ED_STATUS'].first);
      GlobalData().coEdStatus = List<String>.from(raw['CoEd_Status']);
    }

    // ===== LANGUAGE =====
    if (master.containsKey('LANGUAGE_OF_INSTRUCTION')) {
      final raw = Map<String, dynamic>.from(master['LANGUAGE_OF_INSTRUCTION'].first);
      GlobalData().languages = List<String>.from(raw['language']);
    }

    // ===== ANNUAL INCOME =====
    if (master.containsKey('ANNUAL_INCOME')) {
      final list = master['ANNUAL_INCOME'] as List;
      GlobalData().annualIncome =
          list.map((e) => e['name'].toString()).toList();
    }

    // ===== OCCUPATION =====
    if (master.containsKey('OCCUPATION')) {
      final list = master['OCCUPATION'] as List;
      GlobalData().occupations =
          list.map((e) => e['name'].toString()).toList();
    }

    // ===== QUALIFICATION =====
    if (master.containsKey('QUALIFICATION')) {
      final list = master['QUALIFICATION'] as List;
      GlobalData().qualification =
          list.map((e) => e['name'].toString()).toList();
    }

    // ===== COURSES =====
    if (master.containsKey('COURSES')) {
      final list = master['COURSES'] as List;
      GlobalData().courses = list
          .map((e) => Course.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    // ===== SCHOOL TYPES =====
    if (master.containsKey('TYPES_OF_SCHOOL')) {
      final list = master['TYPES_OF_SCHOOL'] as List;
      GlobalData().schoolTypes = list
          .map((e) => SchoolType.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    // ===== STATES + CITIES =====
    if (master.containsKey('INDIA_STATES_CITIES')) {
      final raw =
      Map<String, dynamic>.from(master['INDIA_STATES_CITIES']);

      GlobalData().states = raw.keys.map((e) => e.toString()).toList();
      GlobalData().citiesByState = raw.map(
            (k, v) => MapEntry(k.toString(), List<String>.from(v)),
      );
    }

    // ===== ACTIVE CITIES =====
    // ===== ACTIVE CITIES (🔥 FIXED) =====
    if (master.containsKey('ACTIVE_CITIES')) {
      final raw = master['ACTIVE_CITIES'];

      if (raw is Map) {
        GlobalData().activeCities = raw.map(
              (key, value) => MapEntry(
            key.toString(),
            Map<String, dynamic>.from(value),
          ),
        );
      }
    }

  }


}
