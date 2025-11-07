// lib/features/todo/presentation/controllers/todo_controller.dart

import 'package:get/get.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/usecases/get_todos_use_case.dart';
import '../../domain/usecases/create_todo_use_case.dart';
import '../../domain/usecases/update_todo_use_case.dart';
import '../../domain/usecases/toggle_todo_use_case.dart';
import '../../domain/usecases/delete_todo_use_case.dart';

enum TodoFilter { all, active, completed }

class TodoController extends GetxController {
  final GetTodosUseCase getTodosUseCase;
  final CreateTodoUseCase createTodoUseCase;
  final UpdateTodoUseCase updateTodoUseCase;
  final ToggleTodoUseCase toggleTodoUseCase;
  final DeleteTodoUseCase deleteTodoUseCase;

  TodoController({
    required this.getTodosUseCase,
    required this.createTodoUseCase,
    required this.updateTodoUseCase,
    required this.toggleTodoUseCase,
    required this.deleteTodoUseCase,
  });

  final _allTodos = <TodoEntity>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = Rxn<String>();
  final _currentFilter = TodoFilter.all.obs;

  List<TodoEntity> get allTodos => _allTodos;
  bool get isLoading => _isLoading.value;
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
    loadTodos();
  }

  void setFilter(TodoFilter filter) {
    _currentFilter.value = filter;
  }

  Future<void> loadTodos() async {
    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      final todos = await getTodosUseCase();
      
      // Sort by createdAt descending (newest first)
      todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _allTodos.value = todos;
      print('[TodoController] Loaded ${todos.length} todos successfully');
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

  Future<void> createTodo({required String text, bool completed = false}) async {
    try {
      final todo = await createTodoUseCase(text: text, completed: completed);
      
      // Add new todo to list (at beginning)
      _allTodos.insert(0, todo);

      Get.snackbar(
        'Sukses',
        '✓ Todo berhasil dibuat!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
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
        '✓ Todo berhasil diupdate!',
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
            ? '✓ Todo ditandai selesai'
            : '○ Todo ditandai belum selesai',
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
}