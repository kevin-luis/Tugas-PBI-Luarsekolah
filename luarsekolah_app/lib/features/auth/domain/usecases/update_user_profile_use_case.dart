import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';

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