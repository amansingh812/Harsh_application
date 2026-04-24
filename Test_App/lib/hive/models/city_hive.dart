import 'package:hive/hive.dart';

part 'city_hive.g.dart';

@HiveType(typeId: 2)
class CityHive {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String slug;

  CityHive({
    required this.name,
    required this.slug,
  });
}
