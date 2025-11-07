import '../entities/todo_entity.dart';

abstract class TodoRepository {
  Future<List<TodoEntity>> getTodos({bool? completed});
  Future<TodoEntity> createTodo({required String text, bool completed = false});
  Future<TodoEntity> updateTodo({required String id, String? text, bool? completed});
  Future<TodoEntity> toggleTodoCompletion(String id);
  Future<bool> deleteTodo(String id);
}