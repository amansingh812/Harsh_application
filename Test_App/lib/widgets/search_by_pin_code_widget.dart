import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_scout/widgets/app_elevated_button.dart';
import '../global/global_data.dart';
import 'my_bottomNavigator.dart';
import 'package:dio/dio.dart';

class SearchByPinCodeWidget extends StatefulWidget {
  const SearchByPinCodeWidget({super.key});

  @override
  State<SearchByPinCodeWidget> createState() => _SearchByPinCodeWidgetState();
}

class _SearchByPinCodeWidgetState extends State<SearchByPinCodeWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> suggestions = [];
  final Dio _dio = Dio();

  void _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }

    const String apiKey =
        "AIzaSyDNYm-0_zjDSzsnkpcnYgF8eGbmcEexwI8"; // Replace with actual API key
    final String apiUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&components=country:in";

    try {
      final response = await _dio.get(apiUrl);
      if (response.statusCode == 200) {
        List<dynamic> predictions = response.data['predictions'];
        setState(() {
          suggestions = predictions
              .where((place) => place['description']
                  .toString()
                  .toLowerCase()
                  .contains('bengaluru'))
              .map((place) => {
                    'description': place['description'].toString(),
                    'place_id': place['place_id'].toString(),
                  })
              .toList();
        });
      }
    } catch (e) {
      print("Error fetching suggestions: $e");
    }
  }

  void _onSuggestionSelected(String selectedPlace, String placeId) async {
    const String apiKey =
        "AIzaSyDNYm-0_zjDSzsnkpcnYgF8eGbmcEexwI8"; // Replace with your actual API key
    final String detailsApiUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    try {
      final response = await _dio.get(detailsApiUrl);

      if (response.statusCode == 200) {
        final result = response.data['result'];
        String areaName = selectedPlace.split(',').first.trim();

        // Extract latitude and longitude
        double lat = result['geometry']['location']['lat'];
        double lng = result['geometry']['location']['lng'];

        // Fetch pincode using reverse geocoding
        _getPincodeFromLatLng(lat, lng);

        // Update global data and UI
        _searchController.text = areaName;
        GlobalData().areaName = areaName;

        setState(() {
          suggestions = [];
        });

        print("Area: $areaName");
      } else {
        print(
            "Error: Failed to fetch place details. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching place details: $e");
    }
  }

  void _getPincodeFromLatLng(double lat, double lng) async {
    const String apiKey =
        "AIzaSyDNYm-0_zjDSzsnkpcnYgF8eGbmcEexwI8"; // Replace with your actual API key
    final String geocodeUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey";

    try {
      final response = await _dio.get(geocodeUrl);

      if (response.statusCode == 200) {
        final results = response.data['results'];
        print(results);
        String? pincode;

        for (var result in results) {
          for (var component in result['address_components']) {
            if (component['types'].contains('postal_code')) {
              pincode = component['long_name'];
              break;
            }
          }
          if (pincode != null) break;
        }

        print("Pincode: $pincode");
        GlobalData().pincode = pincode ?? "Not Available";
      } else {
        print(
            "Error: Failed to fetch pincode. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching pincode: $e");
    }
  }

  void _onSubmit() {
    String query = _searchController.text.trim();
    GlobalData().areaName = query;
    GlobalData().pincode = ""; // Reset pincode

    // Close the BottomSheet and navigate
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavigatorClass()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _searchController,
          onChanged: _fetchSuggestions,
          decoration: InputDecoration(
            labelText: "Find by area name or PIN Code",
            hintText: "Enter PIN Code / Area name",
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.search),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9 ]")),
          ],
        ),
        const SizedBox(height: 8),
        if (suggestions.isNotEmpty)
          Container(
            height: 200,
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(suggestions[index]['description']!),
                  onTap: () => _onSuggestionSelected(
                    suggestions[index]['description']!,
                    suggestions[index]['place_id']!,
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        AppElevatedButton(onPressed: _onSubmit, text: 'Submit'),
      ],
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_scout/widgets/app_elevated_button.dart';
import 'package:school_scout/widgets/app_text_form_field.dart';
import '../apis/api_service.dart';
import '../global/global_data.dart';
import 'my_bottomNavigator.dart';
import 'package:dio/dio.dart';

class SearchByPinCodeWidget extends StatefulWidget {
  const SearchByPinCodeWidget({super.key});

  @override
  State<SearchByPinCodeWidget> createState() => _SearchByPinCodeWidgetState();
}

class _SearchByPinCodeWidgetState extends State<SearchByPinCodeWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<String> suggestions = [];
  final Dio _dio = Dio();

  void _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }

    const String apiKey = "ihbNGNtZIxB79zcPnj7A_EolE1"; // Replace with actual API key
    final String apiUrl =
        "https://api.olamaps.com/v1/autocomplete?query=$query&api_key=$apiKey";

    try {
      final response = await _dio.get(apiUrl);
      if (response.statusCode == 200) {
        List<dynamic> results = response.data['predictions'];
        setState(() {
          suggestions =
              results.map((place) => place['description'].toString()).toList();
        });
      }
    } catch (e) {
      print("Error fetching suggestions: $e");
    }
  }

  void _onSuggestionSelected(String selectedPlace) {
    _searchController.text = selectedPlace;
    GlobalData().areaName = selectedPlace;
    GlobalData().pincode = "";
    setState(() {
      suggestions = [];
    });
  }

  void _onSubmit() {
    String query = _searchController.text.trim();
    GlobalData().areaName = query;
    GlobalData().pincode = ""; // Reset pincode

    // Close the BottomSheet and navigate
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavigatorClass()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _searchController,
          onChanged: _fetchSuggestions,
          decoration: InputDecoration(
            labelText: "Find by area name or PIN Code",
            hintText: "Enter PIN Code / Area name",
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.search),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9 ]")),
          ],
        ),
        const SizedBox(height: 8),
        if (suggestions.isNotEmpty)
          Container(
            height: 200,
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(suggestions[index]),
                  onTap: () => _onSuggestionSelected(suggestions[index]),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        AppElevatedButton(onPressed: _onSubmit, text: 'Submit'),
      ],
    );
  }
}*/

/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_scout/widgets/app_elevated_button.dart';
import 'package:school_scout/widgets/app_text_form_field.dart';

import '../apis/api_service.dart';
import '../global/global_data.dart';
import '../screens/home/maps_view_page.dart';
import 'my_bottomNavigator.dart';

class SearchByPinCodeWidget extends StatefulWidget {
  const SearchByPinCodeWidget({super.key});

  @override
  State<SearchByPinCodeWidget> createState() => _SearchByPinCodeWidgetState();
}

class _SearchByPinCodeWidgetState extends State<SearchByPinCodeWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<String> filteredAreas = [];
  List<User> filteredSchools = [];
  int schoolCount = 0;

  void _getAreaDetails(String query) {
    setState(() {
      if (RegExp(r'^\d+$').hasMatch(query)) {
        // If query is a PIN code (numbers only), store it in GlobalData
        GlobalData().pincode = query;
        GlobalData().areaName = ""; // Clear areaName if PIN code is entered
      } else {
        // If it's an area name, store it in GlobalData
        GlobalData().areaName = query;
        GlobalData().pincode = ""; // Clear pincode if areaName is entered
      }
    });
  }

  void _filterSchools() {
    setState(() {
      filteredSchools = GlobalData().users.where((school) {
        if (GlobalData().pincode.isNotEmpty) {
          return school.address.pincode == GlobalData().pincode;
        } else if (GlobalData().areaName.isNotEmpty) {
          return school.address.area.toLowerCase() ==
              GlobalData().areaName.toLowerCase();
        }
        return false; // Default case if neither is provided
      }).toList();

      schoolCount = filteredSchools.length;
    });
  }

  void _onSubmit() {
    String query = _searchController.text.trim();
    _getAreaDetails(query);

    // Filter schools based on the stored values in GlobalData
    _filterSchools();

    // Close the BottomSheet
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavigatorClass()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Ensure it doesn't take full height
      children: [
        AppTextFormField(
          title: "Find by area name or PIN Code",
          hintText: "Enter PIN Code / Area name",
          textEditingController: _searchController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9 ]")),
          ],
        ),
        const SizedBox(height: 12),
        */
/*ElevatedButton(
          onPressed: _onSubmit,
          child: const Text("Submit"),
        ),*/ /*

        AppElevatedButton(onPressed: _onSubmit, text: 'Submit')
      ],
    );
  }
}
*/
