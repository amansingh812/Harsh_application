import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import '../constants/pin_code_constants.dart';
import '../global/global_data.dart';
import '../global/location_notifier.dart';
import '../screens/launch/home_loader_screen.dart';
import '../themes/app_colors.dart';

class LocationModal {
  static Future<String?> show(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _LocationSheet(),
    );
  }
}

class _LocationSheet extends StatefulWidget {
  const _LocationSheet();

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}


class _LocationSheetState extends State<_LocationSheet> {
  String selectedCity =
  GlobalData().city.isNotEmpty ? GlobalData().city : 'Bangalore';
  static Position? _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredCities = [];
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();

    final activeCitiesMap = GlobalData().activeCities;
    filteredCities = GlobalData().activeCities.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
      ..sort((a, b) =>
          a['city'].toString().compareTo(b['city'].toString()));

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dragHandle(),
          const SizedBox(height: 14),

          const Center(
            child: Text(
              'Select Your City',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),

          const SizedBox(height: 16),

          _searchField(),
          const SizedBox(height: 16),
          _useCurrentLocation(context),
          const SizedBox(height: 22),

          const Text(
            'Popular Cities',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSoft,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(child: _cityGrid(context)),
        ],
      ),
    );
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 48,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        final query = value.toLowerCase();

        final cities = GlobalData().activeCities.values
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        setState(() {
          filteredCities = cities.where((city) {
            return city['city']
                .toString()
                .toLowerCase()
                .contains(query);
          }).toList()
            ..sort((a, b) =>
                a['city'].toString().compareTo(b['city'].toString()));
        });
      },
      decoration: InputDecoration(
        hintText: 'Search city...',
        prefixIcon: const Icon(Icons.search, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _useCurrentLocation(BuildContext context) {
    return GestureDetector(
      onTap: _isFetchingLocation ? null : () async {
        setState(() {
          _isFetchingLocation = true;
        });

        try {
          await _getCurrentLocation();
          if (mounted) {
            Navigator.pop(context, GlobalData().city);
            LocationNotifier.notify();
            bottomNavKey.currentState?.goToHome();
          }
        } catch (e) {
          print('Error getting location: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not fetch location. Using default city.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isFetchingLocation = false;
            });
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isFetchingLocation)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            else
              const Icon(
                Icons.my_location,
                size: 18,
                color: AppColors.primary,
              ),
            const SizedBox(width: 6),
            Text(
              _isFetchingLocation ? 'Fetching location...' : 'Use my current location',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cityGrid(BuildContext context) {
    final activeCitiesMap = GlobalData().activeCities;

    // 🔒 safety
    if (activeCitiesMap.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // ✅ convert MAP → LIST for GridView
    final cities = filteredCities;


    return GridView.builder(
      itemCount: cities.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (_, index) {
        final cityData = cities[index] as Map<String, dynamic>;
        final String cityName = cityData['city'];
        final String stateName = cityData['state'];

        final isSelected = selectedCity == cityName;

        if (cities.isEmpty) {
          return const Center(
            child: Text(
              "No city found 😕",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            _setCity(cityData); // 🔥 pass full map if needed
            Navigator.pop(context, cityName);
            LocationNotifier.notify();
            bottomNavKey.currentState?.goToHome();
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey.shade300,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cityName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stateName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


  _setCity(Map<String, dynamic> city) {
    GlobalData().city = city['city'];
    GlobalData().pincode = city['pincode'];
  }


  Future<void> _getCurrentLocation() async {
    loc.Location location = loc.Location();
    print('Location starting');
    print('Location starting');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();

      if (!serviceEnabled) {
        print("User denied enabling GPS.");
        _setDefaultLocation();
        throw Exception('GPS not enabled');
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setDefaultLocation();
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setDefaultLocation();
      throw Exception('Location permission denied forever');
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _currentPosition = position;

      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      if (placemarks.isNotEmpty) {
        GlobalData().pincode =
            placemarks.reversed.last.postalCode?.trim() ?? '';

        String cityName = placemarks.reversed.last.locality?.trim() ?? '';
        GlobalData().city = normalizeCityName(cityName);

        print('PINCODE FROM MAPS: ${GlobalData().pincode}');
        print('CITY FROM MAPS: ${GlobalData().city}');
      } else {
        _setDefaultLocation();
        throw Exception('No location data found');
      }
    } catch (e) {
      print('Error in getting position: $e');
      _setDefaultLocation();
      throw e;
    }
  }

  void _setDefaultLocation() {
    final String cityPincode = _getPinCodeFromCity(GlobalData().city);
    GlobalData().city = GlobalData().city;
    GlobalData().pincode = cityPincode;
    print(
        "Using default location: Pincode - ${GlobalData().pincode}, City - ${GlobalData().city}");
  }

  String _getPinCodeFromCity(String city) {
    final match = PinCodeConstants.cities.firstWhere(
          (c) => c.city.toLowerCase() == city.toLowerCase(),
      orElse: () => const CityInfo(
        city: 'Bangalore',
        pincode: '560001',
        state: 'Karnataka',
      ),
    );

    return match.pincode;
  }

  String normalizeCityName(String city) {
    Map<String, String> cityMap = {
      "bengaluru": "Bangalore",
      "gurugram": "Gurgaon",
      "vadodara": "Baroda",
      "thiruvananthapuram": "Trivandrum",
      "prayagraj": "Allahabad",
      "kolkata": "Calcutta",
      "mumbai": "Bombay",
    };

    return cityMap[city.toLowerCase()] ?? city;
  }

}