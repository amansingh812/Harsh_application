import '../../apis/api_service.dart';
import '../models/feature_facility_hive.dart';
import 'feature_from_hive.dart';

extension FeatureFacilityFromHive on FeatureFacilityHive {
  FeatureFacility toFeatureFacility() {
    return FeatureFacility(
      name: name,
      features: features.map((f) => f.toFeature()).toList(),
    );
  }
}
