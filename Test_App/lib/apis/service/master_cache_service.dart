import 'package:hive/hive.dart';

import '../../constants/hive_keys.dart';

class MasterCacheService {
  static final _box = Hive.box('masterData');

  static int get version =>
      _box.get(HiveKeys.masterVersion, defaultValue: 0);

 /* static Map<String, dynamic>? get data =>
      _box.get(HiveKeys.masterData);*/
  static Map<String, dynamic>? get data {
    final raw = _box.get(HiveKeys.masterData);

    if (raw == null) return null;

    return Map<String, dynamic>.from(
      raw.map(
            (key, value) => MapEntry(
          key.toString(),
          value is Map
              ? Map<String, dynamic>.from(value)
              : value,
        ),
      ),
    );
  }

  static void saveVersion(int v) =>
      _box.put(HiveKeys.masterVersion, v);

  static void saveData(Map<String, dynamic> data) =>
      _box.put(HiveKeys.masterData, data);
}
