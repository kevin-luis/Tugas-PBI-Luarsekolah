// lib/features/home/domain/usecases/get_popular_classes_use_case.dart

import '../entities/class_entity.dart';
import '../repositories/home_repository.dart';

class GetPopularClassesUseCase {
  final HomeRepository repository;

  GetPopularClassesUseCase(this.repository);

  Future<List<ClassEntity>> call() async {
    return await repository.getPopularClasses();
  }
}