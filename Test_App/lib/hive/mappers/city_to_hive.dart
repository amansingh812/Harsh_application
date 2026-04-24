import '../../apis/api_service.dart';
import '../models/city_hive.dart';

extension CityToHive on City {
  CityHive toHive() {
    return CityHive(
      name: name,
      slug: slug,
    );
  }
}
