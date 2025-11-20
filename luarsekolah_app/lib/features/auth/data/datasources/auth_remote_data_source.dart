import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String phoneNumber, String password);
  Future<UserModel> loginWithGoogle();
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('Login gagal');
      }

      return UserModel(
        id: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? email,
        phoneNumber: user.phoneNumber,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(
    String name,
    String email,
    String phoneNumber,
    String password,
  ) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('Registrasi gagal');
      }

      // Update display name
      await user.updateDisplayName(name);
      await user.reload();

      return UserModel(
        id: user.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    // TODO: Implement Google Sign In
    throw UnimplementedError('Google Sign In belum diimplementasikan');
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Gagal logout');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      return UserModel(
        id: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        phoneNumber: user.phoneNumber,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    } catch (e) {
      throw AuthException('Gagal mendapatkan user');
    }
  }

  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('Email tidak terdaftar');
      case 'wrong-password':
        return AuthException('Password salah');
      case 'email-already-in-use':
        return AuthException('Email sudah terdaftar');
      case 'invalid-email':
        return AuthException('Format email tidak valid');
      case 'weak-password':
        return AuthException('Password terlalu lemah');
      case 'user-disabled':
        return AuthException('Akun dinonaktifkan');
      case 'too-many-requests':
        return AuthException('Terlalu banyak percobaan. Coba lagi nanti');
      case 'network-request-failed':
        return AuthException('Koneksi internet bermasalah');
      default:
        return AuthException('Terjadi kesalahan: ${e.message}');
    }
  }
}