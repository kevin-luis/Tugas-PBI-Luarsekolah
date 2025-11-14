import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../models/todo_firebase_model.dart'; // ✅ UBAH INI (tadinya todo_model.dart)

class TodoFirebaseRepositoryImpl implements TodoRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TodoFirebaseRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get reference to user's todos collection
  CollectionReference _getUserTodosCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('todos');
  }

  @override
  Future<List<TodoEntity>> getTodos({bool? completed}) async {
    try {
      print('[FirebaseTodoRepository] Fetching todos for user: ${_auth.currentUser?.uid}');

      Query query = _getUserTodosCollection().orderBy('createdAt', descending: true);

      // Filter by completed status if specified
      if (completed != null) {
        query = query.where('completed', isEqualTo: completed);
      }

      final snapshot = await query.get();
      print('[FirebaseTodoRepository] Retrieved ${snapshot.docs.length} todos');

      final todos = snapshot.docs.map((doc) {
        try {
          // ✅ UBAH: Gunakan TodoFirebaseModel.fromFirestore()
          return TodoFirebaseModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>
          ).toEntity();
        } catch (e) {
          print('[FirebaseTodoRepository] Error parsing todo ${doc.id}: $e');
          return null;
        }
      }).whereType<TodoEntity>().toList();

      return todos;
    } on FirebaseException catch (e) {
      print('[FirebaseTodoRepository] FirebaseException: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseError(e));
    } catch (e, stackTrace) {
      print('[FirebaseTodoRepository] Error: $e');
      print('[FirebaseTodoRepository] StackTrace: $stackTrace');
      throw Exception('Gagal memuat todo: $e');
    }
  }

  @override
  Future<TodoEntity> createTodo({
    required String text,
    bool completed = false,
  }) async {
    try {
      final now = DateTime.now();
      final todoData = {
        'text': text,
        'completed': completed,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      print('[FirebaseTodoRepository] Creating todo: $todoData');

      final docRef = await _getUserTodosCollection().add(todoData);
      
      // Get the created document
      final doc = await docRef.get();
      
      // ✅ UBAH: Gunakan TodoFirebaseModel.fromFirestore()
      return TodoFirebaseModel.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>
      ).toEntity();
    } on FirebaseException catch (e) {
      print('[FirebaseTodoRepository] Create error: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseError(e));
    } catch (e) {
      print('[FirebaseTodoRepository] Error creating todo: $e');
      throw Exception('Gagal membuat todo: $e');
    }
  }

  @override
  Future<TodoEntity> updateTodo({
    required String id,
    String? text,
    bool? completed,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (text != null) updateData['text'] = text;
      if (completed != null) updateData['completed'] = completed;

      print('[FirebaseTodoRepository] Updating todo $id: $updateData');

      await _getUserTodosCollection().doc(id).update(updateData);

      // Get the updated document
      final doc = await _getUserTodosCollection().doc(id).get();
      
      if (!doc.exists) {
        throw Exception('Todo tidak ditemukan');
      }

      // ✅ UBAH: Gunakan TodoFirebaseModel.fromFirestore()
      return TodoFirebaseModel.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>
      ).toEntity();
    } on FirebaseException catch (e) {
      print('[FirebaseTodoRepository] Update error: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseError(e));
    } catch (e) {
      print('[FirebaseTodoRepository] Error updating todo: $e');
      throw Exception('Gagal mengupdate todo: $e');
    }
  }

  @override
  Future<TodoEntity> toggleTodoCompletion(String id) async {
    try {
      print('[FirebaseTodoRepository] Toggling todo $id');

      // Get current todo
      final doc = await _getUserTodosCollection().doc(id).get();
      
      if (!doc.exists) {
        throw Exception('Todo tidak ditemukan');
      }

      final data = doc.data() as Map<String, dynamic>;
      final currentCompleted = data['completed'] ?? false;

      // Toggle completed status
      await _getUserTodosCollection().doc(id).update({
        'completed': !currentCompleted,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Get updated document
      final updatedDoc = await _getUserTodosCollection().doc(id).get();

      // ✅ UBAH: Gunakan TodoFirebaseModel.fromFirestore()
      return TodoFirebaseModel.fromFirestore(
        updatedDoc as DocumentSnapshot<Map<String, dynamic>>
      ).toEntity();
    } on FirebaseException catch (e) {
      print('[FirebaseTodoRepository] Toggle error: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseError(e));
    } catch (e) {
      print('[FirebaseTodoRepository] Error toggling todo: $e');
      throw Exception('Gagal toggle todo: $e');
    }
  }

  @override
  Future<bool> deleteTodo(String id) async {
    try {
      print('[FirebaseTodoRepository] Deleting todo $id');

      await _getUserTodosCollection().doc(id).delete();

      print('[FirebaseTodoRepository] Todo deleted successfully');
      return true;
    } on FirebaseException catch (e) {
      print('[FirebaseTodoRepository] Delete error: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseError(e));
    } catch (e) {
      print('[FirebaseTodoRepository] Error deleting todo: $e');
      throw Exception('Gagal menghapus todo: $e');
    }
  }

  /// Handle Firebase errors with user-friendly messages
  String _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Anda tidak memiliki izin untuk melakukan operasi ini';
      case 'unavailable':
        return 'Layanan Firebase tidak tersedia. Periksa koneksi internet Anda';
      case 'not-found':
        return 'Data tidak ditemukan';
      case 'already-exists':
        return 'Data sudah ada';
      case 'resource-exhausted':
        return 'Kuota penggunaan Firebase habis';
      case 'failed-precondition':
        return 'Operasi gagal karena kondisi yang tidak terpenuhi';
      case 'aborted':
        return 'Operasi dibatalkan';
      case 'out-of-range':
        return 'Nilai di luar jangkauan';
      case 'unimplemented':
        return 'Fitur belum diimplementasikan';
      case 'internal':
        return 'Terjadi kesalahan internal';
      case 'deadline-exceeded':
        return 'Waktu operasi habis';
      case 'cancelled':
        return 'Operasi dibatalkan';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }

  /// Get real-time todos stream (bonus feature)
  Stream<List<TodoEntity>> getTodosStream({bool? completed}) {
    try {
      Query query = _getUserTodosCollection().orderBy('createdAt', descending: true);

      if (completed != null) {
        query = query.where('completed', isEqualTo: completed);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            // ✅ UBAH: Gunakan TodoFirebaseModel.fromFirestore()
            return TodoFirebaseModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>
            ).toEntity();
          } catch (e) {
            print('[FirebaseTodoRepository] Error parsing todo in stream: $e');
            return null;
          }
        }).whereType<TodoEntity>().toList();
      });
    } catch (e) {
      print('[FirebaseTodoRepository] Error creating stream: $e');
      throw Exception('Gagal membuat stream: $e');
    }
  }

  /// Batch delete completed todos
  Future<int> deleteCompletedTodos() async {
    try {
      final snapshot = await _getUserTodosCollection()
          .where('completed', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('[FirebaseTodoRepository] Deleted ${snapshot.docs.length} completed todos');
      
      return snapshot.docs.length;
    } on FirebaseException catch (e) {
      print('[FirebaseTodoRepository] Batch delete error: ${e.code}');
      throw Exception(_handleFirebaseError(e));
    } catch (e) {
      print('[FirebaseTodoRepository] Error in batch delete: $e');
      throw Exception('Gagal menghapus todos: $e');
    }
  }
}