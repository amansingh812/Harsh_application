import 'package:hive/hive.dart';

import 'address_hive.dart';
import 'feature_facility_hive.dart';
import 'feature_hive.dart';

part 'user_hive.g.dart';

@HiveType(typeId: 0)
class UserHive extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String schoolName;

  @HiveField(3)
  final String shortName;

  @HiveField(4)
  final String slug;

  @HiveField(5)
  final String email;

  @HiveField(6)
  final String phoneNo;

  @HiveField(7)
  final String website;

  @HiveField(8)
  final String logo;

  @HiveField(9)
  final String about;

  @HiveField(10)
  final String boards;

  @HiveField(11)
  final String boardsSlug;

  @HiveField(12)
  final String medium;

  @HiveField(13)
  final String format;

  @HiveField(14)
  final String ownership;

  @HiveField(15)
  final String coedStatus;

  @HiveField(16)
  final String academicSession;

  @HiveField(17)
  final String classesOffered;

  @HiveField(18)
  final String level;

  @HiveField(19)
  final List<String> languagesTaught;

  @HiveField(20)
  final String builtInArea;

  @HiveField(21)
  final String yearOfEstablishment;

  @HiveField(22)
  final String numberOfStudents;

  @HiveField(23)
  final String studentTeacherRatio;

  @HiveField(24)
  final String scholarshipProgram;

  @HiveField(25)
  final String dayScholarsAllowed;

  @HiveField(26)
  final String timings;

  @HiveField(27)
  final String dayWiseSchedule;

  @HiveField(28)
  final String verifiedBySchool;

  @HiveField(29)
  final String views;

  @HiveField(30)
  final String brochure;

  @HiveField(31)
  final String schoolResults;

  @HiveField(32)
  final String faqs;

  @HiveField(33)
  final String feeAvailableSessValues;

  @HiveField(34)
  final String myUnknownColumn;

  @HiveField(35)
  final String virtualTour;

  @HiveField(36)
  final bool isLiked;

  // LISTS
  @HiveField(37)
  final List<String> galleryImages;

  @HiveField(38)
  final List<String> galleryVideos;

  // NESTED OBJECTS
  @HiveField(39)
  final AddressHive address;

  @HiveField(40)
  final List<FeatureFacilityHive> featureFacilities;

  UserHive({
    required this.id,
    required this.name,
    required this.schoolName,
    required this.shortName,
    required this.slug,
    required this.email,
    required this.phoneNo,
    required this.website,
    required this.logo,
    required this.about,
    required this.boards,
    required this.boardsSlug,
    required this.medium,
    required this.format,
    required this.ownership,
    required this.coedStatus,
    required this.academicSession,
    required this.classesOffered,
    required this.level,
    required this.languagesTaught,
    required this.builtInArea,
    required this.yearOfEstablishment,
    required this.numberOfStudents,
    required this.studentTeacherRatio,
    required this.scholarshipProgram,
    required this.dayScholarsAllowed,
    required this.timings,
    required this.dayWiseSchedule,
    required this.verifiedBySchool,
    required this.views,
    required this.brochure,
    required this.schoolResults,
    required this.faqs,
    required this.feeAvailableSessValues,
    required this.myUnknownColumn,
    required this.virtualTour,
    required this.isLiked,
    required this.galleryImages,
    required this.galleryVideos,
    required this.address,
    required this.featureFacilities,
  });
}



