// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeatureHiveAdapter extends TypeAdapter<FeatureHive> {
  @override
  final int typeId = 4;

  @override
  FeatureHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeatureHive(
      icon: fields[0] as String,
      name: fields[1] as String,
      exist: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FeatureHive obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.icon)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.exist);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeatureHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
