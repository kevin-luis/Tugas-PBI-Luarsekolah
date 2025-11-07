import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class GetTodosUseCase {
  final TodoRepository repository;

  GetTodosUseCase(this.repository);

  Future<List<TodoEntity>> call({bool? completed}) async {
    return await repository.getTodos(completed: completed);
  }
}