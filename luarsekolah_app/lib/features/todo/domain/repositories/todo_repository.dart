import '../entities/todo_entity.dart';

abstract class TodoRepository {
  Future<List<TodoEntity>> getTodos({bool? completed});
  
  // ✅ NEW: Pagination methods
  Future<List<TodoEntity>> getTodosPaginated({
    bool? completed,
    int limit = 20,
    String? lastDocumentId,
  });
  
  Future<TodoEntity> createTodo({required String text, bool completed = false});
  Future<TodoEntity> updateTodo({required String id, String? text, bool? completed});
  Future<TodoEntity> toggleTodoCompletion(String id);
  Future<bool> deleteTodo(String id);
  
  // ✅ NEW: Batch create for dummy data
  Future<void> batchCreateTodos(List<Map<String, dynamic>> todosData);
}