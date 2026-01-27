/// Request status enum
enum RequestStatus {
  pending,
  accepted,
  rejected,
  cancelled,
}

/// Food request model for FoodLoop
class FoodRequest {
  final String id;
  final String listingId;
  final String donorId; // User who created the listing
  final String receiverId; // User who requested the food
  final RequestStatus status;
  final String? message; // Optional message from receiver
  final DateTime createdAt;
  final DateTime? respondedAt; // When donor accepted/rejected

  const FoodRequest({
    required this.id,
    required this.listingId,
    required this.donorId,
    required this.receiverId,
    required this.status,
    this.message,
    required this.createdAt,
    this.respondedAt,
  });

  bool get isPending => status == RequestStatus.pending;
  bool get isAccepted => status == RequestStatus.accepted;
  bool get isRejected => status == RequestStatus.rejected;

  factory FoodRequest.fromJson(Map<String, dynamic> json) {
    return FoodRequest(
      id: json['id'] as String,
      listingId: json['listingId'] as String,
      donorId: json['donorId'] as String,
      receiverId: json['receiverId'] as String,
      status: _parseStatus(json['status'] as String?),
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }

  static RequestStatus _parseStatus(String? status) {
    switch (status) {
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      case 'cancelled':
        return RequestStatus.cancelled;
      case 'pending':
      default:
        return RequestStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listingId': listingId,
      'donorId': donorId,
      'receiverId': receiverId,
      'status': status.name,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  FoodRequest copyWith({
    String? id,
    String? listingId,
    String? donorId,
    String? receiverId,
    RequestStatus? status,
    String? message,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return FoodRequest(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      donorId: donorId ?? this.donorId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}

