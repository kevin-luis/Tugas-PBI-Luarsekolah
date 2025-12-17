import 'package:luarsekolah_app/features/todo/domain/entities/todo_entity.dart';
import 'package:luarsekolah_app/features/todo/domain/repositories/todo_repository.dart';

class GetTodosUseCase {
  final TodoRepository repository;

  GetTodosUseCase(this.repository);

  Future<List<TodoEntity>> call({bool? completed}) async {
    return await repository.getTodos(completed: completed);
  }
}