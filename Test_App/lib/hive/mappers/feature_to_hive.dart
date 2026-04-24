
import '../../apis/api_service.dart';
import '../models/feature_hive.dart';

extension FeatureToHive on Feature {
  FeatureHive toHive() {
    return FeatureHive(
      icon: icon,
      name: name,
      exist: exist,
    );
  }
}
