/// Complaint status enum
enum ComplaintStatus {
  submitted,
  underReview,
  resolved,
}

/// Complaint category enum
enum ComplaintCategory {
  foodQuality,
  pickupIssue,
  userBehavior,
  listingIssue,
  other,
}

/// Complaint model for FoodLoop
class Complaint {
  final String id;
  final String listingId;
  final String complainantId; // User who submitted the complaint
  final String? againstUserId; // User being complained against (optional)
  final ComplaintCategory category;
  final String description;
  final ComplaintStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? adminNotes; // Admin notes when resolving

  const Complaint({
    required this.id,
    required this.listingId,
    required this.complainantId,
    this.againstUserId,
    required this.category,
    required this.description,
    this.status = ComplaintStatus.submitted,
    required this.createdAt,
    this.resolvedAt,
    this.adminNotes,
  });

  bool get isSubmitted => status == ComplaintStatus.submitted;
  bool get isUnderReview => status == ComplaintStatus.underReview;
  bool get isResolved => status == ComplaintStatus.resolved;

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as String,
      listingId: json['listingId'] as String,
      complainantId: json['complainantId'] as String,
      againstUserId: json['againstUserId'] as String?,
      category: _parseCategory(json['category'] as String?),
      description: json['description'] as String,
      status: _parseStatus(json['status'] as String?),
      createdAt: _parseDateTime(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null
          ? _parseDateTime(json['resolvedAt'])
          : null,
      adminNotes: json['adminNotes'] as String?,
    );
  }

  static ComplaintCategory _parseCategory(String? category) {
    switch (category) {
      case 'foodQuality':
        return ComplaintCategory.foodQuality;
      case 'pickupIssue':
        return ComplaintCategory.pickupIssue;
      case 'userBehavior':
        return ComplaintCategory.userBehavior;
      case 'listingIssue':
        return ComplaintCategory.listingIssue;
      case 'other':
      default:
        return ComplaintCategory.other;
    }
  }

  static ComplaintStatus _parseStatus(String? status) {
    switch (status) {
      case 'underReview':
        return ComplaintStatus.underReview;
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'submitted':
      default:
        return ComplaintStatus.submitted;
    }
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
      'complainantId': complainantId,
      'againstUserId': againstUserId,
      'category': category.name,
      'description': description,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'adminNotes': adminNotes,
    };
  }

  Complaint copyWith({
    String? id,
    String? listingId,
    String? complainantId,
    String? againstUserId,
    ComplaintCategory? category,
    String? description,
    ComplaintStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? adminNotes,
  }) {
    return Complaint(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      complainantId: complainantId ?? this.complainantId,
      againstUserId: againstUserId ?? this.againstUserId,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}

