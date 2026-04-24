import 'package:flutter/material.dart';

import '../apis/master_api_dart.dart';
import '../global/global_data.dart';
import '../screens/other/search_page.dart'; // Adjust the import path as necessary

class CustomSearchWidget extends StatefulWidget {
  @override
  _CustomSearchWidgetState createState() => _CustomSearchWidgetState();
}

class _CustomSearchWidgetState extends State<CustomSearchWidget> {
  @override
  Widget build(BuildContext context) {
    final globalData = GlobalData();
    CityData cityData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: globalData.selectedSchoolType.isNotEmpty
                  ? globalData.selectedSchoolType
                  : globalData.getSchoolTypeNames().first,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    globalData.updateSelectedSchoolType(newValue);

                    print(newValue);
                  });
                } else {
                  globalData.updateSelectedSchoolType(
                      globalData.getSchoolTypeNames().first);
                }
              },
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              ),
              items: <String>[
                'Day School',
                'Boarding School',
                'Day Boarding School',
                'Play School'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    '$value in ${GlobalData().city}',
                    // Assuming you want to display city here
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(

          margin: const EdgeInsets.all(8.0),
          child: TextFormField(
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
            onChanged: (value) {
              globalData.updateSearchQuery(value);
            },
            decoration: InputDecoration(
              hintText: 'What are you looking for',
              hintStyle: TextStyle(fontSize: 14, fontFamily: 'Roboto'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),

              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      // Add logic for search
                    },
                  ),
                  /*  const SizedBox(
                    height: 24,
                    child: VerticalDivider(
                      color: Colors.black,
                      thickness: 1,
                      width: 10,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: Colors.purple),
                    onPressed: () {
                      // Add logic for voice search
                    },
                  ),*/
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
