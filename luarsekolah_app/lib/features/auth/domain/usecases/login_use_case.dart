import 'package:dartz/dartz.dart';
import 'package:luarsekolah_app/features/auth/domain/entities/user_entity.dart';
import 'package:luarsekolah_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:luarsekolah_app/core/error/failures.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}