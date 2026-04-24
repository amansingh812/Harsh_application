import '../apis/remove_shortlisted_school_service.dart';

void removeSchool(String schoolId, String userId) async {
  final removeService = RemoveShortlistedSchoolService();

  final result = await removeService.removeShortlistedSchool(
    schoolId: schoolId,
    shortListedBy: userId,
  );

  if (result['success']) {
    print('School removed successfully: ${result['info']}');
  } else {
    print('Error: ${result['message']}');
  }
}
