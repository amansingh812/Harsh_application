import '../../apis/api_service.dart';
import '../../apis/search_schools_service.dart';


class SearchSchoolsMapper {
  final SearchSchoolsService _service = SearchSchoolsService();

  Future<List<User>> searchAsUsers({
    required String city,
    required String area,
    required String board,
    required String schoolName,
    required String pinCode,
  }) async {
    final result = await _service.searchSchools(
      city: city,
      area: area,
      board: board,
      schoolName: schoolName,
      pinCode: pinCode,
    );

    if (result['statusCode'] == '200') {
      final List list = result['schooldetailslist'] ?? [];
      return list.map((e) => User.fromJson(e)).toList();
    }

    return [];
  }
}
