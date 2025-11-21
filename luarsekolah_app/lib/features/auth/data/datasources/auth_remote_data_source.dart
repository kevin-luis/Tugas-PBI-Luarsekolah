import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String phoneNumber, String password);
  Future<UserModel> loginWithGoogle();
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> updateUserProfile(String userId, String name);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  // PENTING: Nama collection untuk user data
  static const String _usersCollection = 'users'; // <-- Pastikan ini 'users'

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

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

      // Ambil data lengkap dari Firestore collection 'users'
      final userDoc = await firestore
          .collection(_usersCollection) // <-- Menggunakan 'users'
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return UserModel(
          id: user.uid,
          name: userData['name'] ?? user.displayName ?? 'User',
          email: user.email ?? email,
          phoneNumber: userData['phoneNumber'],
          createdAt: (userData['createdAt'] as Timestamp?)?.toDate() ?? 
                     user.metadata.creationTime ?? 
                     DateTime.now(),
        );
      }

      // Fallback jika data Firestore tidak ada
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

      // Update display name di Firebase Auth
      await user.updateDisplayName(name);
      await user.reload();

      final userModel = UserModel(
        id: user.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      // Simpan ke Firestore collection 'users' dengan document ID = user.uid
      await firestore
          .collection(_usersCollection) // <-- Menggunakan 'users'
          .doc(user.uid) // <-- Document ID sama dengan Firebase Auth UID
          .set({
            'name': name,
            'email': email,
            'phoneNumber': phoneNumber,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return userModel;
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

      // Ambil data lengkap dari Firestore collection 'users'
      final userDoc = await firestore
          .collection(_usersCollection) // <-- Menggunakan 'users'
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return UserModel(
          id: user.uid,
          name: userData['name'] ?? user.displayName ?? 'User',
          email: user.email ?? '',
          phoneNumber: userData['phoneNumber'],
          createdAt: (userData['createdAt'] as Timestamp?)?.toDate() ?? 
                     user.metadata.creationTime ?? 
                     DateTime.now(),
        );
      }

      // Fallback jika data Firestore tidak ada
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

  @override
  Future<void> updateUserProfile(String userId, String name) async {
    try {
      await firestore
          .collection(_usersCollection) // <-- Menggunakan 'users'
          .doc(userId)
          .update({
            'name': name,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw AuthException('Gagal mengupdate profil: ${e.toString()}');
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
