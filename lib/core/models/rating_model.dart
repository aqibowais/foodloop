/// Rating model for FoodLoop
class Rating {
  final String id;
  final String listingId;
  final String raterId; // User who gave the rating
  final String ratedUserId; // User being rated
  final int stars; // 1-5 stars
  final String? comment; // Optional comment
  final DateTime createdAt;

  const Rating({
    required this.id,
    required this.listingId,
    required this.raterId,
    required this.ratedUserId,
    required this.stars,
    this.comment,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as String,
      listingId: json['listingId'] as String,
      raterId: json['raterId'] as String,
      ratedUserId: json['ratedUserId'] as String,
      stars: json['stars'] as int,
      comment: json['comment'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    } else if (value != null) {
      return (value as dynamic).toDate();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listingId': listingId,
      'raterId': raterId,
      'ratedUserId': ratedUserId,
      'stars': stars,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Rating copyWith({
    String? id,
    String? listingId,
    String? raterId,
    String? ratedUserId,
    int? stars,
    String? comment,
    DateTime? createdAt,
  }) {
    return Rating(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      raterId: raterId ?? this.raterId,
      ratedUserId: ratedUserId ?? this.ratedUserId,
      stars: stars ?? this.stars,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

