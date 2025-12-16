import 'package:dartz/dartz.dart';
import 'package:luarsekolah_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:luarsekolah_app/core/error/failures.dart';

class UpdateUserProfileUseCase {
  final AuthRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String userId,
    required String name,
    String? phoneNumber,
  }) async {
    return await repository.updateUserProfile(
      userId: userId,
      name: name,
      phoneNumber: phoneNumber,
    );
  }
}