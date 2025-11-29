// lib/features/todo/domain/usecases/get_todos_paginated_use_case.dart

import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class GetTodosPaginatedUseCase {
  final TodoRepository repository;

  GetTodosPaginatedUseCase(this.repository);

  Future<List<TodoEntity>> call({
    bool? completed,
    int limit = 20,
    String? lastDocumentId,
  }) async {
    return await repository.getTodosPaginated(
      completed: completed,
      limit: limit,
      lastDocumentId: lastDocumentId,
    );
  }
}