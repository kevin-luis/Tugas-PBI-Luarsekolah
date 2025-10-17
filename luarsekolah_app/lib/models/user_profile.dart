class UserProfile {
  final String fullName;
  final String? birthDate;
  final String? gender;
  final String? jobStatus;
  final String? address;
  final String? profileImage;

  UserProfile({
    required this.fullName,
    this.birthDate,
    this.gender,
    this.jobStatus,
    this.address,
    this.profileImage,
  });

  // Convert to Map for saving
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'birthDate': birthDate,
      'gender': gender,
      'jobStatus': jobStatus,
      'address': address,
      'profileImage': profileImage,
    };
  }

  // Create from Map
  factory UserProfile.fromMap(Map<String, String?> map) {
    return UserProfile(
      fullName: map['fullName'] ?? '',
      birthDate: map['birthDate'],
      gender: map['gender'],
      jobStatus: map['jobStatus'],
      address: map['address'],
      profileImage: map['profileImage'],
    );
  }

  // Create empty profile
  factory UserProfile.empty() {
    return UserProfile(
      fullName: '',
      birthDate: null,
      gender: null,
      jobStatus: null,
      address: null,
      profileImage: null,
    );
  }

  // Copy with method for updates
  UserProfile copyWith({
    String? fullName,
    String? birthDate,
    String? gender,
    String? jobStatus,
    String? address,
    String? profileImage,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      jobStatus: jobStatus ?? this.jobStatus,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
