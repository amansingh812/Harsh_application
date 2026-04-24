// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserHiveAdapter extends TypeAdapter<UserHive> {
  @override
  final int typeId = 0;

  @override
  UserHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserHive(
      id: fields[0] as String,
      name: fields[1] as String,
      schoolName: fields[2] as String,
      shortName: fields[3] as String,
      slug: fields[4] as String,
      email: fields[5] as String,
      phoneNo: fields[6] as String,
      website: fields[7] as String,
      logo: fields[8] as String,
      about: fields[9] as String,
      boards: fields[10] as String,
      boardsSlug: fields[11] as String,
      medium: fields[12] as String,
      format: fields[13] as String,
      ownership: fields[14] as String,
      coedStatus: fields[15] as String,
      academicSession: fields[16] as String,
      classesOffered: fields[17] as String,
      level: fields[18] as String,
      languagesTaught: (fields[19] as List).cast<String>(),
      builtInArea: fields[20] as String,
      yearOfEstablishment: fields[21] as String,
      numberOfStudents: fields[22] as String,
      studentTeacherRatio: fields[23] as String,
      scholarshipProgram: fields[24] as String,
      dayScholarsAllowed: fields[25] as String,
      timings: fields[26] as String,
      dayWiseSchedule: fields[27] as String,
      verifiedBySchool: fields[28] as String,
      views: fields[29] as String,
      brochure: fields[30] as String,
      schoolResults: fields[31] as String,
      faqs: fields[32] as String,
      feeAvailableSessValues: fields[33] as String,
      myUnknownColumn: fields[34] as String,
      virtualTour: fields[35] as String,
      isLiked: fields[36] as bool,
      galleryImages: (fields[37] as List).cast<String>(),
      galleryVideos: (fields[38] as List).cast<String>(),
      address: fields[39] as AddressHive,
      featureFacilities: (fields[40] as List).cast<FeatureFacilityHive>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserHive obj) {
    writer
      ..writeByte(41)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.schoolName)
      ..writeByte(3)
      ..write(obj.shortName)
      ..writeByte(4)
      ..write(obj.slug)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.phoneNo)
      ..writeByte(7)
      ..write(obj.website)
      ..writeByte(8)
      ..write(obj.logo)
      ..writeByte(9)
      ..write(obj.about)
      ..writeByte(10)
      ..write(obj.boards)
      ..writeByte(11)
      ..write(obj.boardsSlug)
      ..writeByte(12)
      ..write(obj.medium)
      ..writeByte(13)
      ..write(obj.format)
      ..writeByte(14)
      ..write(obj.ownership)
      ..writeByte(15)
      ..write(obj.coedStatus)
      ..writeByte(16)
      ..write(obj.academicSession)
      ..writeByte(17)
      ..write(obj.classesOffered)
      ..writeByte(18)
      ..write(obj.level)
      ..writeByte(19)
      ..write(obj.languagesTaught)
      ..writeByte(20)
      ..write(obj.builtInArea)
      ..writeByte(21)
      ..write(obj.yearOfEstablishment)
      ..writeByte(22)
      ..write(obj.numberOfStudents)
      ..writeByte(23)
      ..write(obj.studentTeacherRatio)
      ..writeByte(24)
      ..write(obj.scholarshipProgram)
      ..writeByte(25)
      ..write(obj.dayScholarsAllowed)
      ..writeByte(26)
      ..write(obj.timings)
      ..writeByte(27)
      ..write(obj.dayWiseSchedule)
      ..writeByte(28)
      ..write(obj.verifiedBySchool)
      ..writeByte(29)
      ..write(obj.views)
      ..writeByte(30)
      ..write(obj.brochure)
      ..writeByte(31)
      ..write(obj.schoolResults)
      ..writeByte(32)
      ..write(obj.faqs)
      ..writeByte(33)
      ..write(obj.feeAvailableSessValues)
      ..writeByte(34)
      ..write(obj.myUnknownColumn)
      ..writeByte(35)
      ..write(obj.virtualTour)
      ..writeByte(36)
      ..write(obj.isLiked)
      ..writeByte(37)
      ..write(obj.galleryImages)
      ..writeByte(38)
      ..write(obj.galleryVideos)
      ..writeByte(39)
      ..write(obj.address)
      ..writeByte(40)
      ..write(obj.featureFacilities);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
