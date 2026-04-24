class FilterSchoolRequest {
  final String primaryCategory;
  final String city;
  final List<String> areas;
  final List<String> boards;
  final String gender;
  final String medium;
  final String level;
  final String type;
  final List<String> classes;
  final List<String> langTaught;
  final int limit;
  final int offset;
  final String academicSession;

  FilterSchoolRequest({
    required this.primaryCategory,
    required this.city,
    required this.areas,
    required this.boards,
    required this.gender,
    required this.medium,
    required this.level,
    required this.type,
    required this.classes,
    required this.langTaught,
    required this.limit,
    required this.offset,
    required this.academicSession,
  });

  // ✅ ADD THIS METHOD
  FilterSchoolRequest copyWith({
    String? primaryCategory,
    String? city,
    List<String>? areas,
    List<String>? boards,
    List<String>? classes,
    String? gender,
    String? medium,
    String? level,
    String? type,
    List<String>? langTaught,
    int? limit,
    int? offset,
    String? academicSession,
  }) {
    return FilterSchoolRequest(
      primaryCategory: primaryCategory ?? this.primaryCategory,
      city: city ?? this.city,
      areas: areas ?? this.areas,
      boards: boards ?? this.boards,
      gender: gender ?? this.gender,
      medium: medium ?? this.medium,
      level: level ?? this.level,
      type: type ?? this.type,
      langTaught: langTaught ?? this.langTaught,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      classes: classes ?? this.classes,
        academicSession : academicSession ?? this.academicSession,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "city": city,
      "areas": areas,
      "boards": boards,
      "gender": gender,
      "medium": medium,
      "level": level,
      "type": type,
      "langTaught": langTaught,
      "limit": limit,
      "offset": offset,
      "classes": classes,
      "academicSession":academicSession,
    };
  }
}
