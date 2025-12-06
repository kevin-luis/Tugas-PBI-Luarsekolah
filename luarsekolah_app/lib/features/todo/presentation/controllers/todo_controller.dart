// lib/features/todo/presentation/controllers/todo_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/usecases/get_todos_use_case.dart';
import '../../domain/usecases/get_todos_paginated_use_case.dart';
import '../../domain/usecases/create_todo_use_case.dart';
import '../../domain/usecases/update_todo_use_case.dart';
import '../../domain/usecases/toggle_todo_use_case.dart';
import '../../domain/usecases/delete_todo_use_case.dart';
import '../../../../core/services/notification_service.dart';

enum TodoFilter { all, active, completed }

class TodoController extends GetxController {
  final GetTodosUseCase getTodosUseCase;
  final GetTodosPaginatedUseCase getTodosPaginatedUseCase;
  final CreateTodoUseCase createTodoUseCase;
  final UpdateTodoUseCase updateTodoUseCase;
  final ToggleTodoUseCase toggleTodoUseCase;
  final DeleteTodoUseCase deleteTodoUseCase;
  final NotificationService notificationService;

  TodoController({
    required this.getTodosUseCase,
    required this.getTodosPaginatedUseCase,
    required this.createTodoUseCase,
    required this.updateTodoUseCase,
    required this.toggleTodoUseCase,
    required this.deleteTodoUseCase,
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

  /// Initial load with pagination
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

  /// Load more todos (for pagination)
  Future<void> loadMoreTodos() async {
    if (_isLoadingMore.value || !_hasMoreData.value || _allTodos.isEmpty) {
      return;
    }

    _isLoadingMore.value = true;

    try {
      final lastDocId = _allTodos.last.id;

      final newTodos = await getTodosPaginatedUseCase(
        limit: 20,
        lastDocumentId: lastDocId,
      );

      if (newTodos.isEmpty || newTodos.length < 20) {
        _hasMoreData.value = false;
      }

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

  /// Refresh todos
  Future<void> loadTodos() async {
    await loadTodosInitial();
  }

  /// Create new todo
  Future<void> createTodo({required String text, bool completed = false}) async {
    try {
      final todo = await createTodoUseCase(text: text, completed: completed);
      
      _allTodos.insert(0, todo);

      Get.snackbar(
        'Sukses',
        'Todo berhasil dibuat!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF26A69A),
        colorText: Colors.white,
      );

      print('[TodoController] Todo created: ${todo.text}');
    } catch (e) {
      print('[TodoController] Error creating todo: $e');
      
      Get.snackbar(
        'Error',
        'Gagal membuat todo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Update todo
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

      final index = _allTodos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _allTodos[index] = updatedTodo;
      }

      Get.snackbar(
        'Sukses',
        'Todo berhasil diupdate!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF26A69A),
        colorText: Colors.white,
      );
    } catch (e) {
      print('[TodoController] Error updating todo: $e');
      
      Get.snackbar(
        'Error',
        'Gagal mengupdate todo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Toggle todo completion status
  Future<void> toggleComplete(String id) async {
    try {
      final updatedTodo = await toggleTodoUseCase(id);

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
        backgroundColor: updatedTodo.completed 
            ? const Color(0xFF26A69A) 
            : Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('[TodoController] Error toggling todo: $e');
      
      Get.snackbar(
        'Error',
        'Gagal mengupdate: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Delete todo
  Future<void> deleteTodo(String id) async {
    try {
      await deleteTodoUseCase(id);

      _allTodos.removeWhere((t) => t.id == id);

      Get.snackbar(
        'Sukses',
        'Todo berhasil dihapus!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    } catch (e) {
      print('[TodoController] Error deleting todo: $e');
      
      Get.snackbar(
        'Error',
        'Gagal menghapus: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Schedule reminder for todo
  Future<void> scheduleReminder({
    required TodoEntity todo,
    required DateTime scheduledDate,
  }) async {
    try {
      // Generate unique notification ID based on todo ID
      final notificationId = todo.id.hashCode.abs();

      await notificationService.scheduleNotification(
        title: '⏰ Reminder: ${todo.text}',
        body: 'Jangan lupa selesaikan todo ini!',
        scheduledDate: scheduledDate,
        payload: todo.id,
        id: notificationId,
      );

      Get.snackbar(
        'Reminder Dijadwalkan',
        'Kamu akan diingatkan pada ${_formatDateTime(scheduledDate)}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

      print('[TodoController] ✅ Reminder scheduled for: ${todo.text} at $scheduledDate');
    } catch (e) {
      print('[TodoController] Error scheduling reminder: $e');
      
      Get.snackbar(
        'Error',
        'Gagal menjadwalkan reminder: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Cancel reminder for specific todo
  Future<void> cancelReminder(String todoId) async {
    try {
      final notificationId = todoId.hashCode.abs();
      await notificationService.cancelNotification(notificationId);
      
      Get.snackbar(
        'Reminder Dibatalkan',
        'Reminder untuk todo ini telah dibatalkan',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('[TodoController] Error cancelling reminder: $e');
    }
  }

  /// Cancel all reminders
  Future<void> cancelAllReminders() async {
    try {
      await notificationService.cancelAllScheduledNotifications();
      
      Get.snackbar(
        'Sukses',
        'Semua reminder dibatalkan',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('[TodoController] Error cancelling reminders: $e');
    }
  }

  /// Get pending notifications count
  Future<int> getPendingRemindersCount() async {
    try {
      final pending = await notificationService.getPendingNotifications();
      return pending.length;
    } catch (e) {
      print('[TodoController] Error getting pending notifications: $e');
      return 0;
    }
  }

  /// Format DateTime for display
  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final localDate = date.toLocal();
    
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];

    if (localDate.year == now.year &&
        localDate.month == now.month &&
        localDate.day == now.day) {
      return 'Hari ini ${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
    } else if (localDate.year == now.year &&
        localDate.month == now.month &&
        localDate.day == now.day + 1) {
      return 'Besok ${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
    } else {
      return '${localDate.day} ${months[localDate.month - 1]} ${localDate.year}, '
          '${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
    }
  }
}