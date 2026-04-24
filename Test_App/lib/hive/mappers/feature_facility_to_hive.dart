import '../../apis/api_service.dart';
import '../models/feature_facility_hive.dart';
import 'feature_to_hive.dart';

extension FeatureFacilityToHive on FeatureFacility {
  FeatureFacilityHive toHive() {
    return FeatureFacilityHive(
      name: name,
      features: features.map((f) => f.toHive()).toList(),
    );
  }
}
