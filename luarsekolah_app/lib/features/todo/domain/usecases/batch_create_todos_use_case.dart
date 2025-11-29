// lib/features/todo/domain/usecases/batch_create_todos_use_case.dart

import '../repositories/todo_repository.dart';

class BatchCreateTodosUseCase {
  final TodoRepository repository;

  BatchCreateTodosUseCase(this.repository);

  Future<void> call(List<Map<String, dynamic>> todosData) async {
    return await repository.batchCreateTodos(todosData);
  }
}