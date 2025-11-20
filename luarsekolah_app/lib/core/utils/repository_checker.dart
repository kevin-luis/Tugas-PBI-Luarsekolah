// lib/core/utils/repository_checker.dart
// File helper untuk debug - cek repository mana yang aktif

import 'package:get/get.dart';
import '../../features/todo/domain/repositories/todo_repository.dart';
import '../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../features/todo/data/repositories/todo_firebase_repository_impl.dart';

class RepositoryChecker {
  static void checkActiveRepository() {
    try {
      final repository = Get.find<TodoRepository>();
      
      print('=================================');
      print('🔍 REPOSITORY CHECK');
      print('=================================');
      
      if (repository is TodoFirebaseRepositoryImpl) {
        print('✅ MENGGUNAKAN: Firebase Repository');
        print('📍 File: todo_firebase_repository_impl.dart');
        print('💾 Data dari: Firebase Firestore');
        print('👤 Per User: YA (Data terisolasi)');
      } else if (repository is TodoRepositoryImpl) {
        print('❌ MENGGUNAKAN: API Repository');
        print('📍 File: todo_repository_impl.dart');
        print('💾 Data dari: API (https://ls-lms.zoidify.my.id)');
        print('👤 Per User: TIDAK (Data shared)');
        print('');
        print('⚠️  MASALAH DITEMUKAN!');
        print('Anda masih menggunakan API repository.');
        print('');
        print('SOLUSI:');
        print('1. Cari file routes (app_routes.dart / app_pages.dart)');
        print('2. Ganti TodoBinding() → TodoFirebaseBinding()');
        print('3. Import: todo_firebase_binding.dart');
        print('4. Hot restart aplikasi');
      } else {
        print('⚠️  UNKNOWN: Repository type tidak dikenali');
        print('Type: ${repository.runtimeType}');
      }
      
      print('=================================');
    } catch (e) {
      print('=================================');
      print('❌ ERROR: Repository tidak ditemukan');
      print('Error: $e');
      print('');
      print('KEMUNGKINAN PENYEBAB:');
      print('1. Binding belum dijalankan');
      print('2. TodoController belum di-initialize');
      print('3. Navigation ke TodoListPage belum menggunakan binding');
      print('=================================');
    }
  }
}