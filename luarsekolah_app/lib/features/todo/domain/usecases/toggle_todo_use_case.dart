import 'package:luarsekolah_app/features/todo/domain/entities/todo_entity.dart';
import 'package:luarsekolah_app/features/todo/domain/repositories/todo_repository.dart';

class ToggleTodoUseCase {
  final TodoRepository repository;

  ToggleTodoUseCase(this.repository);

  Future<TodoEntity> call(String id) async {
    return await repository.toggleTodoCompletion(id);
  }
}