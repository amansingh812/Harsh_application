import 'package:hive/hive.dart';
import 'feature_hive.dart';

part 'feature_facility_hive.g.dart';

@HiveType(typeId: 3)
class FeatureFacilityHive {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<FeatureHive> features;

  FeatureFacilityHive({
    required this.name,
    required this.features,
  });
}
