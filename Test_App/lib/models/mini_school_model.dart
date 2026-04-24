import 'dart:convert';

class MiniSchool {
  final String id;
  final String name;
  final String rawBoards; // raw JSON string like '["CBSE"]'
  final String classesOffered;
  final String showFees;
  final String addmissionEnabled;
  final String partner;
  final String verified;
  final String area;
  final String pincode;
  final String city;
  MiniSchool({
    required this.id,
    required this.name,
    required this.rawBoards,
    required this.classesOffered,
    required this.showFees,
    required this.addmissionEnabled,
    required this.partner,
    required this.verified,
    required this.area,
    required this.pincode,
    required this.city,
  });

  factory MiniSchool.fromJson(Map<String, dynamic> json) {
    return MiniSchool(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      rawBoards: (json['boards'] ?? '').toString(),
      classesOffered: (json['classesOffered'] ?? '').toString(),
      showFees: (json['showFees'] ?? 'N').toString(),
      addmissionEnabled: (json['addmissionEnabled'] ?? 'N').toString(),
      partner: (json['partner'] ?? 'N').toString(),
      verified: (json['verified'] ?? 'N').toString(),
      area: (json['area'] ?? '').toString(),
      pincode: (json['pincode'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
    );
  }

  /// Parses rawBoards JSON string into a list of board names.
  List<String> get boardsList {
    if (rawBoards.isEmpty) return [];
    try {
      final decoded = json.decode(rawBoards);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    // Fallback: treat as comma-separated
    return rawBoards.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  bool get isVerified => verified == 'Y';
  bool get isPartner => partner == 'Y';
}
