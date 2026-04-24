import 'package:dotted_separator/dotted_separator.dart';
import 'package:hive/hive.dart';
import 'package:school_scout/constants/api_endpoints.dart';
import 'package:school_scout/hive/mappers/user_to_hive_mapper.dart';

import '../constants/common_api_call.dart';
import '../global/global_data.dart';
import '../hive/models/user_hive.dart';
import '../model/filter_schools_request.dart';
import 'api_service.dart';

class FilterSchoolService {

Future<List<User>> filterSchools(FilterSchoolRequest request) async {
  final box = Hive.box<UserHive>('schools');

  try {
    final commonApiCall = CommonApiCall(
      baseUrl: ApiEndpoints.filterSchools, // SAME endpoint as fetchUser
    );

    final response = await commonApiCall.post(request.toJson());

    debugPrint('Filter API response: $response');

    if (!response.containsKey('schooldetailslist')) {
      throw Exception('schooldetailslist not found');
    }

    final List<dynamic> resp = response['schooldetailslist'];
    return resp.map((e) => User.fromJson(e)).toList();


  } catch (e) {
    debugPrint('❌ Filter API failed: $e');
    rethrow;
  }
}
}
