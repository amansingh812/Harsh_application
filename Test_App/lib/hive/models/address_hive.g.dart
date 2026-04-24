// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddressHiveAdapter extends TypeAdapter<AddressHive> {
  @override
  final int typeId = 1;

  @override
  AddressHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddressHive(
      area: fields[0] as String,
      city: fields[1] as CityHive,
      state: fields[2] as String,
      country: fields[3] as String,
      pincode: fields[4] as String,
      address1: fields[5] as String,
      address2: fields[6] as String,
      district: fields[7] as String,
      latitude: fields[8] as String,
      areaSlug: fields[9] as String,
      longitude: fields[10] as String,
      districtSlug: fields[11] as String,
      explorePagePartPath: fields[12] as String,
      locality: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AddressHive obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.area)
      ..writeByte(1)
      ..write(obj.city)
      ..writeByte(2)
      ..write(obj.state)
      ..writeByte(3)
      ..write(obj.country)
      ..writeByte(4)
      ..write(obj.pincode)
      ..writeByte(5)
      ..write(obj.address1)
      ..writeByte(6)
      ..write(obj.address2)
      ..writeByte(7)
      ..write(obj.district)
      ..writeByte(8)
      ..write(obj.latitude)
      ..writeByte(9)
      ..write(obj.areaSlug)
      ..writeByte(10)
      ..write(obj.longitude)
      ..writeByte(11)
      ..write(obj.districtSlug)
      ..writeByte(12)
      ..write(obj.explorePagePartPath)
      ..writeByte(13)
      ..write(obj.locality);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
