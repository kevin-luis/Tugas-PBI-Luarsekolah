import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class UpdateTodoUseCase {
  final TodoRepository repository;

  UpdateTodoUseCase(this.repository);

  Future<TodoEntity> call({
    required String id,
    String? text,
    bool? completed,
  }) async {
    return await repository.updateTodo(
      id: id,
      text: text,
      completed: completed,
    );
  }
}