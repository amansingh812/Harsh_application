

import 'package:school_scout/hive/mappers/address_hive_to_address.dart'; // <-- ADD THIS LINE
import 'package:school_scout/hive/mappers/feature_facility_from_hive.dart';

import '../../apis/api_service.dart';
import '../models/user_hive.dart';

extension UserHiveToUserMapper on UserHive {
  User toUser() {
    return User(
      id: id,
      name: name,
      slug: slug,
      schoolName: schoolName,
      shortName: shortName,
      email: email,
      phoneNo: phoneNo,
      website: website,
      about: about,
      boards: boards,
      boardsSlug: boardsSlug,
      medium: medium,
      format: format,
      classesOffered: classesOffered,
      ownership: ownership,
      coedStatus: coedStatus,
      yearOfEstablishment: yearOfEstablishment,
      builtInArea: builtInArea,
      academicSession: academicSession,
      views: views,
      numberOfStudents: numberOfStudents,
      studentTeacherRatio: studentTeacherRatio,
      timings: timings,
      logo: logo,
      brochure: brochure,
      scholarshipProgram: scholarshipProgram,
      dayScholarsAllowed: dayScholarsAllowed,
      verifiedBySchool: verifiedBySchool,
      isLiked: isLiked,
      galleryImages: galleryImages,
      galleryVideos: galleryVideos,
      virtualTour: virtualTour,
      address: address.toAddress(),
      featureFacilities:
      featureFacilities.map((e) => e.toFeatureFacility()).toList(),
      level: level,
      languagesTaught: languagesTaught,
      dayWiseSchedule: dayWiseSchedule,
      myUnknownColumn: myUnknownColumn,
      faqs: faqs,
      schoolResults: schoolResults,
      feeAvailableSessValues: feeAvailableSessValues,
    );
  }
}
