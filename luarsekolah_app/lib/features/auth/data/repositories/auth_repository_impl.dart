import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(email, password);
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(AuthFailure('Terjadi kesalahan'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.register(
        name,
        email,
        phoneNumber,
        password,
      );
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(AuthFailure('Terjadi kesalahan'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      final result = await remoteDataSource.loginWithGoogle();
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(AuthFailure('Terjadi kesalahan'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Gagal logout'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final result = await remoteDataSource.getCurrentUser();
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Gagal mendapatkan user'));
    }
  }
}