

import '../../apis/api_service.dart';
import '../models/address_hive.dart';

extension AddressFromHive on AddressHive {
  Address toAddress() {
    return Address(
      area: area,
      city: City(
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
