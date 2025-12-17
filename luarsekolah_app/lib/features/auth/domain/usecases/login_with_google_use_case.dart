import 'package:dartz/dartz.dart';
import 'package:luarsekolah_app/features/auth/domain/entities/user_entity.dart';
import 'package:luarsekolah_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:luarsekolah_app/core/error/failures.dart';

class LoginWithGoogleUseCase {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.loginWithGoogle();
  }
}