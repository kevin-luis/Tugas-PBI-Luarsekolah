import 'package:luarsekolah_app/features/course/domain/entities/course_entity.dart';
import 'package:luarsekolah_app/features/course/domain/repositories/course_repository.dart';

class GetAllCoursesUseCase {
  final CourseRepository repository;

  GetAllCoursesUseCase(this.repository);

  Future<List<CourseEntity>> call() async {
    return await repository.getAllCourses();
  }
}