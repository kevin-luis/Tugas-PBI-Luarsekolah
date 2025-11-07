import '../repositories/course_repository.dart';

class CreateCourseUseCase {
  final CourseRepository repository;

  CreateCourseUseCase(this.repository);

  Future<bool> call({
    required String name,
    required String price,
    required List<String> categoryTag,
    String? thumbnail,
    String? rating,
    String? createdBy,
  }) async {
    return await repository.createCourse(
      name: name,
      price: price,
      categoryTag: categoryTag,
      thumbnail: thumbnail,
      rating: rating,
      createdBy: createdBy,
    );
  }
}