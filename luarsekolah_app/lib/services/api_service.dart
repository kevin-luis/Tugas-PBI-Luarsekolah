import 'package:dio/dio.dart';
import '../models/class_model.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://ls-lms.zoidify.my.id/api',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_TOKEN_HERE',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ),
  )..interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ));

  // Get all courses with pagination and filtering
  static Future<Map<String, dynamic>> getCourses({
    int limit = 100,
    int offset = 0,
    List<String>? categoryTag,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (categoryTag != null && categoryTag.isNotEmpty) {
        queryParameters['categoryTag'] = categoryTag.join(',');
      }

      final response = await _dio.get(
        '/courses',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }

      return {
        'success': false,
        'message': 'Failed to fetch courses',
      };
    } on DioException catch (e) {
      print('Error fetching courses: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? e.message ?? 'Network error',
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
      };
    }
  }

  // Get course by ID
  static Future<Map<String, dynamic>> getCourseById(String id) async {
    try {
      final response = await _dio.get('/course/$id');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }

      return {
        'success': false,
        'message': 'Course not found',
      };
    } on DioException catch (e) {
      print('Error fetching course: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? e.message ?? 'Network error',
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
      };
    }
  }

  // Create new course
  static Future<Map<String, dynamic>> createCourse({
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

      print('Creating course with data: $data');

      final response = await _dio.post(
        '/courses',
        data: data,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }

      return {
        'success': false,
        'message': 'Failed to create course',
      };
    } on DioException catch (e) {
      print('Error creating course: ${e.message}');
      print('Response data: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? e.message ?? 'Network error',
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
      };
    }
  }

  // Update course - KIRIM SEMUA DATA, BUKAN PARTIAL
  static Future<Map<String, dynamic>> updateCourse({
    required String id,
    required String name,
    required String price,
    List<String>? categoryTag,
    String? thumbnail,
    String? rating,
  }) async {
    try {
      // Build data object dengan semua field yang diperlukan
      final data = <String, dynamic>{
        'name': name,
        'price': price,
      };
      
      // Add categoryTag if provided
      if (categoryTag != null && categoryTag.isNotEmpty) {
        data['categoryTag'] = categoryTag;
      }
      
      // Add thumbnail if valid URL
      if (thumbnail != null && thumbnail.isNotEmpty && thumbnail.startsWith('http')) {
        data['thumbnail'] = thumbnail;
      }
      
      // Add rating if provided
      if (rating != null && rating.isNotEmpty) {
        data['rating'] = rating;
      }

      print('=== UPDATE REQUEST ===');
      print('ID: $id');
      print('Data: $data');

      final response = await _dio.put(
        '/course/$id',
        data: {'data': data},
      );

      print('=== UPDATE RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.data}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }

      return {
        'success': false,
        'message': 'Failed to update course',
      };
    } on DioException catch (e) {
      print('Error updating course: ${e.message}');
      print('Response: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? e.message ?? 'Network error',
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
      };
    }
  }

  // Delete course
  static Future<Map<String, dynamic>> deleteCourse(String id) async {
    try {
      final response = await _dio.delete(
        '/course/$id',
        data: {},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }

      return {
        'success': false,
        'message': 'Failed to delete course',
      };
    } on DioException catch (e) {
      print('Error deleting course: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? e.message ?? 'Network error',
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred',
      };
    }
  }

  // Get courses by category (helper method)
  static Future<List<ClassModel>> getCoursesByCategory(String category) async {
    final result = await getCourses(categoryTag: [category.toLowerCase()]);
    
    if (result['success'] == true) {
      final List courses = result['data']['courses'] ?? [];
      return courses.map((json) => ClassModel.fromApiJson(json)).toList();
    }
    
    return [];
  }

  // Get all courses as ClassModel list
  static Future<List<ClassModel>> getAllCourses() async {
    final result = await getCourses(limit: 100);
    
    if (result['success'] == true) {
      final List courses = result['data']['courses'] ?? [];
      return courses.map((json) => ClassModel.fromApiJson(json)).toList();
    }
    
    return [];
  }
}