class CityInfo {
  final String city;
  final String pincode;
  final String state;

  const CityInfo({
    required this.city,
    required this.pincode,
    required this.state,
  });
}

class PinCodeConstants {
  static const List<CityInfo> cities = [
    CityInfo(city: 'Bangalore', pincode: '560001', state: 'Karnataka'),
    CityInfo(city: 'Mumbai', pincode: '400001', state: 'Maharashtra'),
    CityInfo(city: 'Delhi', pincode: '110001', state: 'Delhi NCR'),
    CityInfo(city: 'Chennai', pincode: '600001', state: 'Tamil Nadu'),
    CityInfo(city: 'Hyderabad', pincode: '500001', state: 'Telangana'),
    CityInfo(city: 'Pune', pincode: '411001', state: 'Maharashtra'),
  ];
}
