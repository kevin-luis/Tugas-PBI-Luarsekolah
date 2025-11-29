// lib/features/todo/presentation/controllers/todo_controller.dart

import 'package:get/get.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/usecases/get_todos_use_case.dart';
import '../../domain/usecases/get_todos_paginated_use_case.dart';
import '../../domain/usecases/create_todo_use_case.dart';
import '../../domain/usecases/update_todo_use_case.dart';
import '../../domain/usecases/toggle_todo_use_case.dart';
import '../../domain/usecases/delete_todo_use_case.dart';
import '../../domain/usecases/batch_create_todos_use_case.dart';
import '../../../../core/services/notification_service.dart';

enum TodoFilter { all, active, completed }

class TodoController extends GetxController {
  final GetTodosUseCase getTodosUseCase;
  final GetTodosPaginatedUseCase getTodosPaginatedUseCase;
  final CreateTodoUseCase createTodoUseCase;
  final UpdateTodoUseCase updateTodoUseCase;
  final ToggleTodoUseCase toggleTodoUseCase;
  final DeleteTodoUseCase deleteTodoUseCase;
  final BatchCreateTodosUseCase batchCreateTodosUseCase;
  final NotificationService notificationService;

  TodoController({
    required this.getTodosUseCase,
    required this.getTodosPaginatedUseCase,
    required this.createTodoUseCase,
    required this.updateTodoUseCase,
    required this.toggleTodoUseCase,
    required this.deleteTodoUseCase,
    required this.batchCreateTodosUseCase,
    required this.notificationService,
  });

  final _allTodos = <TodoEntity>[].obs;
  final _isLoading = false.obs;
  final _isLoadingMore = false.obs;
  final _hasMoreData = true.obs;
  final _errorMessage = Rxn<String>();
  final _currentFilter = TodoFilter.all.obs;

  List<TodoEntity> get allTodos => _allTodos;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMoreData => _hasMoreData.value;
  String? get errorMessage => _errorMessage.value;
  TodoFilter get currentFilter => _currentFilter.value;

  List<TodoEntity> get filteredTodos {
    switch (_currentFilter.value) {
      case TodoFilter.active:
        return _allTodos.where((todo) => !todo.completed).toList();
      case TodoFilter.completed:
        return _allTodos.where((todo) => todo.completed).toList();
      case TodoFilter.all:
        return _allTodos;
    }
  }

  int get activeCount => _allTodos.where((todo) => !todo.completed).length;
  int get completedCount => _allTodos.where((todo) => todo.completed).length;
  int get totalCount => _allTodos.length;

  @override
  void onInit() {
    super.onInit();
    loadTodosInitial();
  }

  void setFilter(TodoFilter filter) {
    _currentFilter.value = filter;
  }

  /// ✅ NEW: Initial load with pagination
  Future<void> loadTodosInitial() async {
    _isLoading.value = true;
    _errorMessage.value = null;
    _hasMoreData.value = true;

    try {
      final todos = await getTodosPaginatedUseCase(
        limit: 20,
        lastDocumentId: null,
      );

      _allTodos.value = todos;
      
      // If we got less than 20, there's no more data
      if (todos.length < 20) {
        _hasMoreData.value = false;
      }

      print('[TodoController] Loaded ${todos.length} todos initially');
    } catch (e) {
      print('[TodoController] Error loading todos: $e');
      _errorMessage.value = e.toString();
      
      Get.snackbar(
        'Error',
        'Gagal memuat todos: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// ✅ NEW: Load more todos (for pagination)
  Future<void> loadMoreTodos() async {
    if (_isLoadingMore.value || !_hasMoreData.value || _allTodos.isEmpty) {
      return;
    }

    _isLoadingMore.value = true;

    try {
      // Get the last document ID from current list
      final lastDocId = _allTodos.last.id;

      final newTodos = await getTodosPaginatedUseCase(
        limit: 20,
        lastDocumentId: lastDocId,
      );

      if (newTodos.isEmpty || newTodos.length < 20) {
        _hasMoreData.value = false;
      }

      // Add new todos to existing list
      _allTodos.addAll(newTodos);

      print('[TodoController] Loaded ${newTodos.length} more todos. Total: ${_allTodos.length}');
    } catch (e) {
      print('[TodoController] Error loading more todos: $e');
      
      Get.snackbar(
        'Error',
        'Gagal memuat lebih banyak todos: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingMore.value = false;
    }
  }

  /// Original load method (for refresh)
  Future<void> loadTodos() async {
    await loadTodosInitial();
  }

  Future<void> createTodo({required String text, bool completed = false}) async {
    try {
      final todo = await createTodoUseCase(text: text, completed: completed);
      
      // Add new todo to list (at beginning)
      _allTodos.insert(0, todo);

      // Send notification when todo is created
      await notificationService.showLocalNotification(
        title: todo.text,
        body: 'Todo berhasil ditambahkan',
        payload: todo.id,
      );

      Get.snackbar(
        'Sukses',
        'Todo berhasil dibuat!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      print('[TodoController] Todo created and notification sent');
    } catch (e) {
      print('[TodoController] Error creating todo: $e');
      
      Get.snackbar(
        'Error',
        'Gagal membuat todo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateTodo({
    required String id,
    String? text,
    bool? completed,
  }) async {
    try {
      final updatedTodo = await updateTodoUseCase(
        id: id,
        text: text,
        completed: completed,
      );

      // Update in list
      final index = _allTodos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _allTodos[index] = updatedTodo;
      }

      Get.snackbar(
        'Sukses',
        'Todo berhasil diupdate!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('[TodoController] Error updating todo: $e');
      
      Get.snackbar(
        'Error',
        'Gagal mengupdate todo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleComplete(String id) async {
    try {
      final updatedTodo = await toggleTodoUseCase(id);

      // Update in list
      final index = _allTodos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _allTodos[index] = updatedTodo;
      }

      Get.snackbar(
        'Sukses',
        updatedTodo.completed
            ? 'Todo ditandai selesai'
            : 'Todo ditandai belum selesai',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      print('[TodoController] Error toggling todo: $e');
      
      Get.snackbar(
        'Error',
        'Gagal mengupdate: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await deleteTodoUseCase(id);

      // Remove from list
      _allTodos.removeWhere((t) => t.id == id);

      Get.snackbar(
        'Sukses',
        'Todo berhasil dihapus!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('[TodoController] Error deleting todo: $e');
      
      Get.snackbar(
        'Error',
        'Gagal menghapus: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// ✅ NEW: Generate and inject 100 dummy todos
  Future<void> generateDummyTodos() async {
    try {
      _isLoading.value = true;

      final List<Map<String, dynamic>> dummyTodos = [];
      final now = DateTime.now();

      final tasks = [
        'Belajar Flutter Clean Architecture',
        'Mengerjakan tugas kuliah',
        'Meeting dengan tim project',
        'Review code pull request',
        'Menulis dokumentasi API',
        'Testing fitur baru aplikasi',
        'Membaca buku programming',
        'Olahraga pagi',
        'Belanja kebutuhan bulanan',
        'Membayar tagihan listrik',
        'Servis motor/mobil',
        'Backup data penting',
        'Update dependencies project',
        'Refactor kode yang sudah ada',
        'Membuat unit test',
        'Deploy aplikasi ke production',
        'Memperbaiki bug yang dilaporkan',
        'Design mockup UI/UX',
        'Riset teknologi baru',
        'Belajar Dart advanced features',
      ];

      for (var i = 0; i < 100; i++) {
        final randomTask = tasks[i % tasks.length];
        final daysAgo = i; // Each todo created progressively older
        final isCompleted = i % 3 == 0; // Every 3rd todo is completed

        dummyTodos.add({
          'text': '$randomTask #${i + 1}',
          'completed': isCompleted,
          'createdAt': now.subtract(Duration(days: daysAgo, hours: i % 24)),
          'updatedAt': now.subtract(Duration(days: daysAgo, hours: i % 24)),
        });
      }

      await batchCreateTodosUseCase(dummyTodos);

      // Reload todos after injection
      await loadTodosInitial();

      Get.snackbar(
        'Sukses',
        '100 dummy todos berhasil dibuat!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      print('[TodoController] ✅ 100 dummy todos created successfully');
    } catch (e) {
      print('[TodoController] Error generating dummy todos: $e');
      
      Get.snackbar(
        'Error',
        'Gagal membuat dummy todos: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> remindTodo(TodoEntity todo) async {
    try {
      await notificationService.scheduleNotification(
        title: 'Reminder: ${todo.text}',
        body: 'Jangan lupa selesaikan todo ini!',
        delay: const Duration(seconds: 10),
        payload: todo.id,
      );

      Get.snackbar(
        'Reminder Dijadwalkan',
        'Kamu akan diingatkan dalam 10 detik',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      print('[TodoController] ✅ Reminder scheduled for: ${todo.text}');
    } catch (e) {
      print('[TodoController] Error scheduling reminder: $e');
      
      Get.snackbar(
        'Error',
        'Gagal menjadwalkan reminder: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await notificationService.cancelAllScheduledNotifications();
      
      Get.snackbar(
        'Sukses',
        'Semua reminder dibatalkan',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('[TodoController] Error cancelling reminders: $e');
    }
  }
}