import 'package:hive/hive.dart';

part 'feature_hive.g.dart';

@HiveType(typeId: 4)
class FeatureHive extends HiveObject {
  @HiveField(0)
  final String icon;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String exist; // SAME STRING

  FeatureHive({
    required this.icon,
    required this.name,
    required this.exist,
  });
}
