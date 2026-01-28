/// Roles for FoodLoop RBAC.
/// - user: regular user (can donate/receive as individual, family, NGO)
/// - admin: platform admin / moderator
enum UserRole { user, admin }

/// User model for FoodLoop stored in Firestore.
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final String? city;
  final String? area;
  final String? organizationName; // optional, for NGOs
  final String? phoneNumber; // Pakistani phone number (optional)
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = UserRole.user,
    this.city,
    this.area,
    this.organizationName,
    this.phoneNumber,
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: _parseRole(json['role'] as String?),
      city: json['city'] as String?,
      area: json['area'] as String?,
      organizationName: json['organizationName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'city': city,
      'area': area,
      'organizationName': organizationName,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    String? city,
    String? area,
    String? organizationName,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      city: city ?? this.city,
      area: area ?? this.area,
      organizationName: organizationName ?? this.organizationName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
