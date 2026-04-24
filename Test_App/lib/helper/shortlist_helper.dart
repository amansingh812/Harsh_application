import 'package:hive/hive.dart';

import '../apis/api_service.dart';

class ShortlistHelper {
  static Box get _box => Hive.box('shortlist');

  static bool isLiked(User user) {
    return _box.containsKey(user.id);
  }

  static void add(String schoolId) {
    _box.put(schoolId, true);
  }

  static void remove(String schoolId) {
    _box.delete(schoolId);
  }
}
