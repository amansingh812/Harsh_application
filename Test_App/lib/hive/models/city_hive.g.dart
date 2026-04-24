// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CityHiveAdapter extends TypeAdapter<CityHive> {
  @override
  final int typeId = 2;

  @override
  CityHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CityHive(
      name: fields[0] as String,
      slug: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CityHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.slug);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
