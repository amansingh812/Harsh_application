import '../../apis/api_service.dart';
import '../models/address_hive.dart';
import '../models/city_hive.dart';

extension AddressToHive on Address {
  AddressHive toHive() {
    return AddressHive(
      area: area,
      city: CityHive(
        name: city.name,
        slug: city.slug,
      ),
      state: state,
      country: country,
      pincode: pincode,
      address1: address1,
      address2: address2,
      district: district,
      latitude: latitude,
      areaSlug: areaSlug,
      longitude: longitude,
      districtSlug: districtSlug,
      explorePagePartPath: explorePagePartPath,
      locality: locality,
    );
  }
}
