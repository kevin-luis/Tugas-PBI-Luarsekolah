// lib/features/account/domain/usecases/update_profile_usecase.dart

import '../repositories/account_repository.dart';

class UpdateProfileUseCase {
  final AccountRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<bool> call({
    required String name,
    String? photoUrl,
  }) async {
    return await repository.updateProfile(
      name: name,
      photoUrl: photoUrl,
    );
  }
}