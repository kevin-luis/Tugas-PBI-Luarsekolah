import 'package:dio/dio.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../models/course_model.dart';

class CourseRepositoryImpl implements CourseRepository {
  final Dio _dio;

  CourseRepositoryImpl(this._dio);

  @override
  Future<List<CourseEntity>> getAllCourses() async {
    try {
      final response = await _dio.get(
        '/courses',
        queryParameters: {'limit': 100, 'offset': 0},
      );

      if (response.statusCode == 200) {
        final List courses = response.data['courses'] ?? [];
        return courses
            .map((json) => CourseModel.fromJson(json).toEntity())
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching all courses: $e');
      return [];
    }
  }

  @override
  Future<List<CourseEntity>> getCoursesByCategory(String category) async {
    try {
      final response = await _dio.get(
        '/courses',
        queryParameters: {
          'limit': 100,
          'offset': 0,
          'categoryTag': category.toLowerCase(),
        },
      );

      if (response.statusCode == 200) {
        final List courses = response.data['courses'] ?? [];
        return courses
            .map((json) => CourseModel.fromJson(json).toEntity())
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching courses by category: $e');
      return [];
    }
  }

  @override
  Future<CourseEntity?> getCourseById(String id) async {
    try {
      final response = await _dio.get('/course/$id');

      if (response.statusCode == 200) {
        return CourseModel.fromJson(response.data).toEntity();
      }

      return null;
    } catch (e) {
      print('Error fetching course by id: $e');
      return null;
    }
  }

  @override
  Future<bool> createCourse({
    required String name,
    required String price,
    required List<String> categoryTag,
    String? thumbnail,
    String? rating,
    String? createdBy,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'price': price,
        'categoryTag': categoryTag,
      };

      if (thumbnail != null && thumbnail.isNotEmpty && thumbnail.startsWith('http')) {
        data['thumbnail'] = thumbnail;
      }
      if (rating != null && rating.isNotEmpty) {
        data['rating'] = rating;
      }
      if (createdBy != null && createdBy.isNotEmpty) {
        data['createdBy'] = createdBy;
      }

      final response = await _dio.post('/courses', data: data);

      return response.statusCode == 200;
    } catch (e) {
      print('Error creating course: $e');
      return false;
    }
  }

  @override
  Future<bool> updateCourse({
    required String id,
    required String name,
    required String price,
    List<String>? categoryTag,
    String? thumbnail,
    String? rating,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'price': price,
      };

      if (categoryTag != null && categoryTag.isNotEmpty) {
        data['categoryTag'] = categoryTag;
      }

      if (thumbnail != null && thumbnail.isNotEmpty && thumbnail.startsWith('http')) {
        data['thumbnail'] = thumbnail;
      }

      if (rating != null && rating.isNotEmpty) {
        data['rating'] = rating;
      }

      final response = await _dio.put(
        '/course/$id',
        data: {'data': data},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating course: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteCourse(String id) async {
    try {
      final response = await _dio.delete('/course/$id', data: {});

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting course: $e');
      return false;
    }
  }
}