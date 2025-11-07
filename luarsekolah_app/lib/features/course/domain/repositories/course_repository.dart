import '../entities/course_entity.dart';

abstract class CourseRepository {
  Future<List<CourseEntity>> getAllCourses();
  
  Future<List<CourseEntity>> getCoursesByCategory(String category);
  
  Future<CourseEntity?> getCourseById(String id);
  
  Future<bool> createCourse({
    required String name,
    required String price,
    required List<String> categoryTag,
    String? thumbnail,
    String? rating,
    String? createdBy,
  });
  
  Future<bool> updateCourse({
    required String id,
    required String name,
    required String price,
    List<String>? categoryTag,
    String? thumbnail,
    String? rating,
  });
  
  Future<bool> deleteCourse(String id);
}