import '../repositories/course_repository.dart';

class DeleteCourseUseCase {
  final CourseRepository repository;

  DeleteCourseUseCase(this.repository);

  Future<bool> call(String id) async {
    return await repository.deleteCourse(id);
  }
}