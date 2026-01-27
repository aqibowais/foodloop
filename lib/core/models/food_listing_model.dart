/// Food type enum
enum FoodType {
  cooked,
  packaged,
  bakery,
  beverages,
}

/// Listing status enum
enum ListingStatus {
  available,
  reserved,
  completed,
  expired,
}

/// Food listing model for FoodLoop
class FoodListing {
  final String id;
  final String donorId; // User ID of the donor
  final FoodType foodType;
  final String title;
  final String description;
  final int servings; // Approximate number of servings
  final DateTime expiryDate;
  final String city;
  final String area;
  final String? address; // Optional detailed address
  final double? latitude; // Optional for future map integration
  final double? longitude; // Optional for future map integration
  final List<String> imageUrls; // Cloudinary URLs
  final ListingStatus status;
  final String? reservedForUserId; // User ID if reserved
  final DateTime createdAt;
  final DateTime updatedAt;

  const FoodListing({
    required this.id,
    required this.donorId,
    required this.foodType,
    required this.title,
    required this.description,
    required this.servings,
    required this.expiryDate,
    required this.city,
    required this.area,
    this.address,
    this.latitude,
    this.longitude,
    this.imageUrls = const [],
    this.status = ListingStatus.available,
    this.reservedForUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAvailable => status == ListingStatus.available;
  bool get isReserved => status == ListingStatus.reserved;
  bool get isExpired => status == ListingStatus.expired || 
                        DateTime.now().isAfter(expiryDate);
  bool get isUrgent => !isExpired && 
                       DateTime.now().add(const Duration(hours: 6)).isAfter(expiryDate);

  factory FoodListing.fromJson(Map<String, dynamic> json) {
    return FoodListing(
      id: json['id'] as String,
      donorId: json['donorId'] as String,
      foodType: _parseFoodType(json['foodType'] as String?),
      title: json['title'] as String,
      description: json['description'] as String,
      servings: json['servings'] as int,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      city: json['city'] as String,
      area: json['area'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: _parseStatus(json['status'] as String?),
      reservedForUserId: json['reservedForUserId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static FoodType _parseFoodType(String? type) {
    switch (type) {
      case 'cooked':
        return FoodType.cooked;
      case 'packaged':
        return FoodType.packaged;
      case 'bakery':
        return FoodType.bakery;
      case 'beverages':
        return FoodType.beverages;
      default:
        return FoodType.cooked;
    }
  }

  static ListingStatus _parseStatus(String? status) {
    switch (status) {
      case 'reserved':
        return ListingStatus.reserved;
      case 'completed':
        return ListingStatus.completed;
      case 'expired':
        return ListingStatus.expired;
      case 'available':
      default:
        return ListingStatus.available;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donorId': donorId,
      'foodType': foodType.name,
      'title': title,
      'description': description,
      'servings': servings,
      'expiryDate': expiryDate.toIso8601String(),
      'city': city,
      'area': area,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'status': status.name,
      'reservedForUserId': reservedForUserId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  FoodListing copyWith({
    String? id,
    String? donorId,
    FoodType? foodType,
    String? title,
    String? description,
    int? servings,
    DateTime? expiryDate,
    String? city,
    String? area,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    ListingStatus? status,
    String? reservedForUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodListing(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      foodType: foodType ?? this.foodType,
      title: title ?? this.title,
      description: description ?? this.description,
      servings: servings ?? this.servings,
      expiryDate: expiryDate ?? this.expiryDate,
      city: city ?? this.city,
      area: area ?? this.area,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      reservedForUserId: reservedForUserId ?? this.reservedForUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

