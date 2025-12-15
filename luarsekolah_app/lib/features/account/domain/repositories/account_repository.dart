// lib/features/account/domain/repositories/account_repository.dart
abstract class AccountRepository {
  Future<bool> updateProfile({
    required String name,
    String? photoUrl,
  });
}