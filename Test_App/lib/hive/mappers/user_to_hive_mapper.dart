import 'package:school_scout/hive/mappers/address_to_hive_mapper.dart';
import 'package:school_scout/hive/mappers/feature_facility_to_hive.dart';
import '../../apis/api_service.dart';


import '../models/user_hive.dart';

extension UserToHiveMapper on User {
  UserHive toHive() {
    return UserHive(
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
      dayWiseSchedule: dayWiseSchedule,
      faqs: faqs,
      feeAvailableSessValues: feeAvailableSessValues,
      languagesTaught: languagesTaught,
      level: level,
      myUnknownColumn: myUnknownColumn,
      schoolResults: schoolResults,
      address: address.toHive(),
      featureFacilities:
      featureFacilities.map((e) => e.toHive()).toList(),


    );
  }
}
