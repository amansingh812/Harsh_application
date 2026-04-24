import 'package:hive/hive.dart';
import 'city_hive.dart';

part 'address_hive.g.dart';

@HiveType(typeId: 1)
class AddressHive {
  @HiveField(0)
  final String area;

  @HiveField(1)
  final CityHive city;

  @HiveField(2)
  final String state;

  @HiveField(3)
  final String country;

  @HiveField(4)
  final String pincode;

  @HiveField(5)
  final String address1;

  @HiveField(6)
  final String address2;

  @HiveField(7)
  final String district;

  @HiveField(8)
  final String latitude;

  @HiveField(9)
  final String areaSlug;

  @HiveField(10)
  final String longitude;

  @HiveField(11)
  final String districtSlug;

  @HiveField(12)
  final String explorePagePartPath;

  @HiveField(13)
  final String locality;

  AddressHive({
    required this.area,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.address1,
    required this.address2,
    required this.district,
    required this.latitude,
    required this.areaSlug,
    required this.longitude,
    required this.districtSlug,
    required this.explorePagePartPath,
    required this.locality,
  });
}
