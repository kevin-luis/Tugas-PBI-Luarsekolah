// lib/features/account/data/repositories/account_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AccountRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<bool> updateProfile({
    required String name,
    String? photoUrl,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return false;

      // Update Firebase Auth Display Name
      await currentUser.updateDisplayName(name);
      if (photoUrl != null) {
        await currentUser.updatePhotoURL(photoUrl);
      }
      await currentUser.reload();

      // Update Firestore
      final updateData = <String, dynamic>{
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update(updateData);

      return true;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}