// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_facility_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeatureFacilityHiveAdapter extends TypeAdapter<FeatureFacilityHive> {
  @override
  final int typeId = 3;

  @override
  FeatureFacilityHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeatureFacilityHive(
      name: fields[0] as String,
      features: (fields[1] as List).cast<FeatureHive>(),
    );
  }

  @override
  void write(BinaryWriter writer, FeatureFacilityHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.features);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeatureFacilityHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
