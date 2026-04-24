import 'package:cloud_firestore/cloud_firestore.dart';
import '../global/global_data.dart';

class MasterFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchMaster() async {
    try {
      final snapshot =
      await _firestore.collection('masterData').get();

      for (final doc in snapshot.docs) {
        final String key = doc.id;
        final dynamic data = doc['data'];

        switch (key) {

          case 'AREAS':
          // data = [ { "Bangalore": [...] } ]
            if (data is List && data.isNotEmpty) {
              final Map<String, dynamic> cityMap = data.first;
              GlobalData().areas =
              List<String>.from(cityMap['Bangalore'] ?? []);
            }
            break;

          case 'BOARD':
            GlobalData().boards =
            List<String>.from(data.first['boards'] ?? []);
            break;

          case 'CO_ED_STATUS':
            GlobalData().coEdStatus =
            List<String>.from(data.first['CoEd_Status'] ?? []);
            break;

          case 'LANGUAGE_OF_INSTRUCTION':
            GlobalData().languages =
            List<String>.from(data.first['language'] ?? []);
            break;

          case 'ANNUAL_INCOME':
            GlobalData().annualIncome =
                data.map<String>((e) => e['name'].toString()).toList();
            break;

          case 'COURSES':
            GlobalData().courses = data
                .map<Course>((e) => Course.fromJson(e))
                .toList();
            break;

          case 'OCCUPATION':
            GlobalData().occupations =
                data.map<String>((e) => e['name'].toString()).toList();
            break;

          case 'QUALIFICATION':
            GlobalData().qualification =
                data.map<String>((e) => e['name'].toString()).toList();
            break;

          case 'TYPES_OF_SCHOOL':
            GlobalData().schoolTypes = data
                .map<SchoolType>((e) => SchoolType.fromJson(e))
                .toList();
            break;
          case 'INDIA_STATES_CITIES':
            GlobalData().states = (data as Map<String, dynamic>).keys.toList();

            GlobalData().citiesByState = (data as Map<String, dynamic>).map(
                  (state, cities) => MapEntry(
                state,
                List<String>.from(cities),
              ),
            );
            break;
          case 'ACTIVE_CITIES':
            final Map<String, dynamic> activeCities =
            Map<String, dynamic>.from(data);

            GlobalData().activeCities = activeCities;
            break;


          default:
          // ignore
            break;
        }
      }

      print('✅ Master data loaded from Firestore');
    } catch (e) {
      print('❌ Firestore master fetch error: $e');
    }
  }
}
