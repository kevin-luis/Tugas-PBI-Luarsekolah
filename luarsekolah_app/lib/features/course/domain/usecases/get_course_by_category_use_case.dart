import 'package:luarsekolah_app/features/course/domain/entities/course_entity.dart';
import 'package:luarsekolah_app/features/course/domain/repositories/course_repository.dart';

class GetCoursesByCategoryUseCase {
  final CourseRepository repository;

  GetCoursesByCategoryUseCase(this.repository);

  Future<List<CourseEntity>> call(String category) async {
    return await repository.getCoursesByCategory(category);
  }
}