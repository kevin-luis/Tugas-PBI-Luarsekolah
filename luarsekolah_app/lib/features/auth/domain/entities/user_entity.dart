// user_entity.dart
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;  // Add this
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt, this.phoneNumber,
    this.photoUrl,  // Add this
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,  // Add this
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,  // Add this
      createdAt: createdAt ?? this.createdAt,
    );
  }
}