import '../../apis/api_service.dart';
import '../models/feature_hive.dart';

extension FeatureFromHive on FeatureHive {
  Feature toFeature() {
    return Feature(
      icon: icon,
      name: name,
      exist: exist,
    );
  }
}
