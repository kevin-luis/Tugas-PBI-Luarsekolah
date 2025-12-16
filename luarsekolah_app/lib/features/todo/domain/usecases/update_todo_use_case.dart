import 'package:luarsekolah_app/features/todo/domain/entities/todo_entity.dart';
import 'package:luarsekolah_app/features/todo/domain/repositories/todo_repository.dart';

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