import '../repositories/todo_repository.dart';

class DeleteTodoUseCase {
  final TodoRepository repository;

  DeleteTodoUseCase(this.repository);

  Future<bool> call(String id) async {
    return await repository.deleteTodo(id);
  }
}