import '../repositories/course_repository.dart';

class UpdateCourseUseCase {
  final CourseRepository repository;

  UpdateCourseUseCase(this.repository);

  Future<bool> call({
    required String id,
    required String name,
    required String price,
    List<String>? categoryTag,
    String? thumbnail,
    String? rating,
  }) async {
    return await repository.updateCourse(
      id: id,
      name: name,
      price: price,
      categoryTag: categoryTag,
      thumbnail: thumbnail,
      rating: rating,
    );
  }
}