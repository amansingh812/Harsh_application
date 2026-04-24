class PollQuestion {
  final String id;
  final String description;
  final String associatedCategory;
  final String ratings;
  final List<String> options;

  PollQuestion({
    required this.id,
    required this.description,
    required this.associatedCategory,
    required this.ratings,
    required this.options,
  });

  // Factory method to create a PollQuestion object from JSON
  factory PollQuestion.fromJson(Map<String, dynamic> json) {
    return PollQuestion(
      id: json['ID'],
      description: json['DESCRIPTIONS'],
      associatedCategory: json['ASSOCIATED_CATEGORY'],
      ratings: json['RATINGS'],
      options: json['OPTIONS']
          .split(','), // Split string to get the options as a list
    );
  }
}
