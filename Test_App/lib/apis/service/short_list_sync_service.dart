import 'package:hive/hive.dart';
import '../fetch_shortlist_service.dart';

class ShortListSyncService {
  static Future<void> syncIfEmpty(String mobileNumber) async {
    final shortlistBox = Hive.box('shortlist');

    // 1️⃣ FIRST: Hive check
    if (shortlistBox.isNotEmpty) {
      print('✅ Shortlist already present locally');
      return;
    }

    print('🌐 Shortlist empty → fetching from server');

    final service = FetchShortlistService();
    final result = await service.fetchShortlistData(mobileNumber);

    if (result['success'] == true) {
      final List<dynamic> list = result['shortedList'] ?? [];

      final Map<String, bool> map = {};

      for (final item in list) {
        final schoolId = item['schoolId'];
        if (schoolId != null) {
          map[schoolId.toString()] = true;
        }
      }

      // 2️⃣ Batch write (fast)
      await shortlistBox.putAll(map);
    }
  }
}
