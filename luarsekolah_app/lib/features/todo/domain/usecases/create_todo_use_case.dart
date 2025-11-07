import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class CreateTodoUseCase {
  final TodoRepository repository;

  CreateTodoUseCase(this.repository);

  Future<TodoEntity> call({required String text, bool completed = false}) async {
    return await repository.createTodo(text: text, completed: completed);
  }
}