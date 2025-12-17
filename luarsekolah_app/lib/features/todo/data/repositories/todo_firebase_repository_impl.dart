import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luarsekolah_app/features/todo/domain/entities/todo_entity.dart';
import 'package:luarsekolah_app/features/todo/domain/repositories/todo_repository.dart';
import 'package:luarsekolah_app/features/todo/data/models/todo_firebase_model.dart';

class TodoFirebaseRepositoryImpl implements TodoRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TodoFirebaseRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

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
      developer.log('Fetching todos for user: ${_auth.currentUser?.uid}', name: 'TodoRepository');

      Query query = _getUserTodosCollection().orderBy('createdAt', descending: true);

      if (completed != null) {
        query = query.where('completed', isEqualTo: completed);
      }

      final snapshot = await query.get();
      developer.log('Retrieved ${snapshot.docs.length} todos', name: 'TodoRepository');

      final todos = snapshot.docs.map((doc) {
        try {
          return TodoFirebaseModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>
          ).toEntity();
        } catch (e) {
          developer.log('Error parsing todo ${doc.id}', name: 'TodoRepository', error: e);
          return null;
        }
      }).whereType<TodoEntity>().toList();

      return todos;
    } on FirebaseException catch (e) {
      developer.log('FirebaseException: ${e.code} - ${e.message}', name: 'TodoRepository', error: e);
      throw Exception(_handleFirebaseError(e));
    } catch (e, stackTrace) {
      developer.log('Error fetching todos', name: 'TodoRepository', error: e, stackTrace: stackTrace);
      throw Exception('Gagal memuat todo: $e');
    }
  }

  @override
  Future<List<TodoEntity>> getTodosPaginated({
    bool? completed,
    int limit = 20,
    String? lastDocumentId,
  }) async {
    try {
      developer.log('Fetching paginated todos (limit: $limit, lastDoc: $lastDocumentId)', name: 'TodoRepository');

      Query query = _getUserTodosCollection()
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (completed != null) {
        query = _getUserTodosCollection()
            .where('completed', isEqualTo: completed)
            .orderBy('createdAt', descending: true)
            .limit(limit);
      }

      if (lastDocumentId != null && lastDocumentId.isNotEmpty) {
        final lastDoc = await _getUserTodosCollection().doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      developer.log('Retrieved ${snapshot.docs.length} paginated todos', name: 'TodoRepository');

      final todos = snapshot.docs.map((doc) {
        try {
          return TodoFirebaseModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>
          ).toEntity();
        } catch (e) {
          developer.log('Error parsing todo ${doc.id}', name: 'TodoRepository', error: e);
          return null;
        }
      }).whereType<TodoEntity>().toList();

      return todos;
    } on FirebaseException catch (e) {
      developer.log('FirebaseException: ${e.code} - ${e.message}', name: 'TodoRepository', error: e);
      throw Exception(_handleFirebaseError(e));
    } catch (e, stackTrace) {
      developer.log('Error fetching paginated todos', name: 'TodoRepository', error: e, stackTrace: stackTrace);
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

      developer.log('Creating todo: $todoData', name: 'TodoRepository');

      final docRef = await _getUserTodosCollection().add(todoData);
      final doc = await docRef.get();
      
      return TodoFirebaseModel.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>
      ).toEntity();
    } on FirebaseException catch (e) {
      developer.log('Create error: ${e.code} - ${e.message}', name: 'TodoRepository', error: e);
      throw Exception(_handleFirebaseError(e));
    } catch (e) {
      developer.log('Error creating todo', name: 'TodoRepository', error: e);
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

      developer.log('Updating todo $id: $updateData', name: 'TodoRepository');

      await _getUserTodosCollection().doc(id).update(updateData);
      final doc = await _getUserTodosCollection().doc(id).get();
      
      if (!doc.exists) {
        throw Exception('Todo tidak ditemukan');
      }

      return TodoFirebaseModel.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>
      ).toEntity();
    } on FirebaseException catch (e) {
      developer.log('Update error: ${e.code} - ${e.message}', name: 'TodoRepository', error: e);
      throw Exception(_handleFirebaseError(e));
    } catch (e) {
      developer.log('Error updating todo', name: 'TodoRepository', error: e);
      throw Exception('Gagal mengupdate todo: $e');
    }
  }

  @override
  Future<TodoEntity> toggleTodoCompletion(String id) async {
    try {
      developer.log('Toggling todo $id', name: 'TodoRepository');

      final doc = await _getUserTodosCollection().doc(id).get();
      
      if (!doc.exists) {
        throw Exception('Todo tidak ditemukan');
      }

      final data = doc.data() as Map<String, dynamic>;
      final currentCompleted = data['completed'] ?? false;

      await _getUserTodosCollection().doc(id).update({
        'completed': !currentCompleted,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      final updatedDoc = await _getUserTodosCollection().doc(id).get();

      return TodoFirebaseModel.fromFirestore(
        updatedDoc as DocumentSnapshot<Map<String, dynamic>>
      ).toEntity();
    } on FirebaseException catch (e) {
      developer.log('Toggle error: ${e.code} - ${e.message}', name: 'TodoRepository', error: e);
      throw Exception(_handleFirebaseError(e));
    } catch (e) {
      developer.log('Error toggling todo', name: 'TodoRepository', error: e);
      throw Exception('Gagal toggle todo: $e');
    }
  }

  @override
  Future<bool> deleteTodo(String id) async {
    try {
      developer.log('Deleting todo $id', name: 'TodoRepository');
      await _getUserTodosCollection().doc(id).delete();
      developer.log('Todo deleted successfully', name: 'TodoRepository');
      return true;
    } on FirebaseException catch (e) {
      developer.log('Delete error: ${e.code} - ${e.message}', name: 'TodoRepository', error: e);
      throw Exception(_handleFirebaseError(e));
    } catch (e) {
      developer.log('Error deleting todo', name: 'TodoRepository', error: e);
      throw Exception('Gagal menghapus todo: $e');
    }
  }

  @override
  Stream<List<TodoEntity>> getTodosStream({bool? completed}) {
    try {
      Query query = _getUserTodosCollection().orderBy('createdAt', descending: true);

      if (completed != null) {
        query = query.where('completed', isEqualTo: completed);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            return TodoFirebaseModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>
            ).toEntity();
          } catch (e) {
            developer.log('Error parsing todo in stream', name: 'TodoRepository', error: e);
            return null;
          }
        }).whereType<TodoEntity>().toList();
      });
    } catch (e) {
      developer.log('Error creating stream', name: 'TodoRepository', error: e);
      throw Exception('Gagal membuat stream: $e');
    }
  }

  @override
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
      developer.log('Deleted ${snapshot.docs.length} completed todos', name: 'TodoRepository');
      
      return snapshot.docs.length;
    } on FirebaseException catch (e) {
      developer.log('Batch delete error: ${e.code}', name: 'TodoRepository', error: e);
      throw Exception(_handleFirebaseError(e));
    } catch (e) {
      developer.log('Error in batch delete', name: 'TodoRepository', error: e);
      throw Exception('Gagal menghapus todos: $e');
    }
  }

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
}