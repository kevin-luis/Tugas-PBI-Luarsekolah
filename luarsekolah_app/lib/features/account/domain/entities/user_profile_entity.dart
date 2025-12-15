// lib/features/account/domain/entities/user_profile_entity.dart

class UserProfileEntity {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;

  UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
  });

  UserProfileEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}