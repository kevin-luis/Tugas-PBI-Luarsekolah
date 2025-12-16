import 'package:dartz/dartz.dart';
import 'package:luarsekolah_app/features/auth/domain/entities/user_entity.dart';
import 'package:luarsekolah_app/core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, UserEntity>> loginWithGoogle();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity?>> getCurrentUser();
  
  Future<Either<Failure, void>> updateUserProfile({
    required String userId,
    required String name,
    String? phoneNumber,
  }); // Tambahkan ini
}