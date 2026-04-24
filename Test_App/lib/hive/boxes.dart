import 'package:hive/hive.dart';
import 'models/user_hive.dart';

class HiveBoxes {
  static Box<UserHive> get schools =>
      Hive.box<UserHive>('schools');
}
