import 'package:dartz/dartz.dart';
import 'package:luarsekolah_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:luarsekolah_app/core/error/failures.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}