import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class GetCoursesByCategoryUseCase {
  final CourseRepository repository;

  GetCoursesByCategoryUseCase(this.repository);

  Future<List<CourseEntity>> call(String category) async {
    return await repository.getCoursesByCategory(category);
  }
}