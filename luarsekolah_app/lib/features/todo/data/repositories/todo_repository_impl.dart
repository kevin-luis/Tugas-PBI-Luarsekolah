import 'package:dio/dio.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  late Dio _dio;
  final String baseUrl = 'https://ls-lms.zoidify.my.id/api';

  TodoRepositoryImpl() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    );
  }

  @override
  Future<List<TodoEntity>> getTodos({bool? completed}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (completed != null) {
        queryParams['completed'] = completed.toString();
      }

      print('[TodoRepository] Fetching todos with params: $queryParams');

      final response = await _dio.get(
        '/todos',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      print('[TodoRepository] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data.containsKey('todos')) {
          final todosRaw = data['todos'];
          print('[TodoRepository] Todos count: ${(todosRaw as List).length}');

          final todos = <TodoEntity>[];
          for (var i = 0; i < todosRaw.length; i++) {
            try {
              final todoJson = todosRaw[i] as Map<String, dynamic>;
              final todo = TodoModel.fromJson(todoJson).toEntity();
              todos.add(todo);
            } catch (e) {
              print('[TodoRepository] Error parsing todo $i: $e');
            }
          }

          print('[TodoRepository] Successfully parsed ${todos.length} todos');
          return todos;
        } else if (data is List) {
          final todos = <TodoEntity>[];
          for (var i = 0; i < data.length; i++) {
            try {
              final todo = TodoModel.fromJson(data[i]).toEntity();
              todos.add(todo);
            } catch (e) {
              print('[TodoRepository] Error parsing todo $i: $e');
            }
          }
          return todos;
        } else {
          throw Exception('Format response tidak sesuai');
        }
      } else {
        throw Exception('Gagal memuat todo (status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[TodoRepository] DioException: ${e.type}');
      print('[TodoRepository] Message: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Koneksi timeout. Periksa koneksi internet Anda.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server tidak merespons. Coba lagi nanti.');
      } else if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('Gagal terhubung ke server: ${e.message}');
      }
    } catch (e, stackTrace) {
      print('[TodoRepository] Error: $e');
      print('[TodoRepository] StackTrace: $stackTrace');
      throw Exception('Gagal memuat todo: $e');
    }
  }

  @override
  Future<TodoEntity> createTodo({
    required String text,
    bool completed = false,
  }) async {
    try {
      final requestData = {
        'text': text,
        'completed': completed,
      };

      print('[TodoRepository] Creating todo with data: $requestData');

      final response = await _dio.post(
        '/todos',
        data: requestData,
      );

      print('[TodoRepository] Create response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TodoModel.fromJson(response.data).toEntity();
      } else {
        throw Exception('Gagal membuat todo (status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[TodoRepository] Create error: ${e.response?.data}');
      throw Exception('Gagal membuat todo: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Gagal membuat todo: $e');
    }
  }

  @override
  Future<TodoEntity> updateTodo({
    required String id,
    String? text,
    bool? completed,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (text != null) data['text'] = text;
      if (completed != null) data['completed'] = completed;

      print('[TodoRepository] Updating todo $id with data: $data');

      final response = await _dio.put(
        '/todos/$id',
        data: data,
      );

      print('[TodoRepository] Update response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return TodoModel.fromJson(response.data).toEntity();
      } else {
        throw Exception('Gagal mengupdate todo (status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[TodoRepository] Update error: ${e.response?.data}');
      throw Exception('Gagal mengupdate todo: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Gagal mengupdate todo: $e');
    }
  }

  @override
  Future<TodoEntity> toggleTodoCompletion(String id) async {
    try {
      print('[TodoRepository] Toggling todo $id');

      final response = await _dio.patch('/todos/$id/toggle');

      print('[TodoRepository] Toggle response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return TodoModel.fromJson(response.data).toEntity();
      } else {
        throw Exception('Gagal toggle todo (status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[TodoRepository] Toggle error: ${e.response?.data}');
      throw Exception('Gagal toggle todo: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Gagal toggle todo: $e');
    }
  }

  @override
  Future<bool> deleteTodo(String id) async {
    try {
      print('[TodoRepository] Deleting todo $id');

      final response = await _dio.delete('/todos/$id');

      print('[TodoRepository] Delete response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.data['success'] ?? true;
      } else {
        throw Exception('Gagal menghapus todo (status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[TodoRepository] Delete error: ${e.response?.data}');
      throw Exception('Gagal menghapus todo: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Gagal menghapus todo: $e');
    }
  }
}