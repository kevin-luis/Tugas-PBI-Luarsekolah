import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class ToggleTodoUseCase {
  final TodoRepository repository;

  ToggleTodoUseCase(this.repository);

  Future<TodoEntity> call(String id) async {
    return await repository.toggleTodoCompletion(id);
  }
}