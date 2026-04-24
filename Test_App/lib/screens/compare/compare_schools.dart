import 'package:flutter/material.dart';

import '../../widgets/location_modal.dart';

class CompareSchools extends StatefulWidget {
  const CompareSchools({super.key});

  @override
  State<CompareSchools> createState() => _CompareSchoolsState();
}

class _CompareSchoolsState extends State<CompareSchools> {
  String _selectedLocation = 'Bangalore';
  final TextEditingController _citySelectionController =
      TextEditingController();

  @override
  void initState() {
    _citySelectionController.text = "Bangalore";
    super.initState();
  }

  @override
  void dispose() {
    _citySelectionController.dispose();
    super.dispose();
  }

  /*void _showLocationModal() {
    LocationModal.show(context, (String selectedLocation) {
      setState(() {
        // _selectedLocation = selectedLocation;
        _citySelectionController.text = selectedLocation;
      });
    });
  }*/
  void _showLocationModal() async {
    String? selectedLocation = await LocationModal.show(context);

    if (selectedLocation != null && selectedLocation.isNotEmpty) {
      setState(() {
        _citySelectionController.text = selectedLocation;
        //_fetchInitialData(); // Refresh school list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showLocationModal,
          child: DropdownMenu<String>(
            controller: _citySelectionController,
            enabled: false,
            dropdownMenuEntries: <String>[
              'Bangalore',
              'Mumbai',
              'Delhi',
              'Chennai'
            ].map<DropdownMenuEntry<String>>((String value) {
              return DropdownMenuEntry<String>(
                value: value,
                label: value,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
