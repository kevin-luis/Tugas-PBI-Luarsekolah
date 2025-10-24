import 'package:dio/dio.dart';


import '../models/todo_model.dart';

class TodoService {
  late Dio _dio;
  final String baseUrl =
      'https://ls-lms.zoidify.my.id/api';

  TodoService() {
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
          // Accept any status code to handle it manually
          return status != null && status < 500;
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    );
  }

  Future<List<TodoModel>> fetchTodos({bool? completed}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (completed != null) {
        queryParams['completed'] = completed.toString();
      }

      print('[TodoService] Fetching todos with params: $queryParams');

      final response = await _dio.get(
        '/todos',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      print('[TodoService] Response status: ${response.statusCode}');
      print('[TodoService] Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Check if data is Map and has 'todos' key
        if (data is Map<String, dynamic> && data.containsKey('todos')) {
          final todosRaw = data['todos'];
          print('[TodoService] Todos raw type: ${todosRaw.runtimeType}');
          print('[TodoService] Todos count: ${(todosRaw as List).length}');

          final todos = <TodoModel>[];
          for (var i = 0; i < todosRaw.length; i++) {
            try {
              final todoJson = todosRaw[i] as Map<String, dynamic>;
              print('[TodoService] Parsing todo $i: ${todoJson['id']}');
              final todo = TodoModel.fromJson(todoJson);
              todos.add(todo);
            } catch (e) {
              print('[TodoService] Error parsing todo $i: $e');
              print('[TodoService] Todo data: ${todosRaw[i]}');
              // Skip this todo and continue
            }
          }

          print('[TodoService] Successfully parsed ${todos.length} todos');
          return todos;
        } else if (data is List) {
          // If response is directly a list
          final todos = <TodoModel>[];
          for (var i = 0; i < data.length; i++) {
            try {
              final todo = TodoModel.fromJson(data[i]);
              todos.add(todo);
            } catch (e) {
              print('[TodoService] Error parsing todo $i: $e');
              // Skip this todo and continue
            }
          }
          return todos;
        } else {
          throw Exception('Format response tidak sesuai: $data');
        }
      } else {
        throw Exception(
            'Gagal memuat todo (status: ${response.statusCode}, message: ${response.data})');
      }
    } on DioException catch (e) {
      print('[TodoService] DioException: ${e.type}');
      print('[TodoService] Message: ${e.message}');
      print('[TodoService] Response: ${e.response?.data}');

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Koneksi timeout. Periksa koneksi internet Anda.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server tidak merespons. Coba lagi nanti.');
      } else if (e.response != null) {
        throw Exception(
            'Server error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Gagal terhubung ke server: ${e.message}');
      }
    } catch (e, stackTrace) {
      print('[TodoService] Error: $e');
      print('[TodoService] StackTrace: $stackTrace');
      throw Exception('Gagal memuat todo: $e');
    }
  }

  Future<TodoModel> createTodo({
    required String text,
    bool completed = false,
  }) async {
    try {
      final requestData = {
        'text': text,
        'completed': completed,
      };

      print('[TodoService] Creating todo with data: $requestData');

      final response = await _dio.post(
        '/todos',
        data: requestData,
      );

      print('[TodoService] Create response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TodoModel.fromJson(response.data);
      } else {
        throw Exception('Gagal membuat todo (status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[TodoService] Create error: ${e.response?.data}');
      throw Exception('Gagal membuat todo: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Gagal membuat todo: $e');
    }
  }

  Future<TodoModel> updateTodo({
    required String id,
    String? text,
    bool? completed,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (text != null) data['text'] = text;
      if (completed != null) data['completed'] = completed;

      print('[TodoService] Updating todo $id with data: $data');

      final response = await _dio.put(
        '/todos/$id',
        data: data,
      );

      print('[TodoService] Update response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return TodoModel.fromJson(response.data);
      } else {
        throw Exception(
            'Gagal mengupdate todo (status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[TodoService] Update error: ${e.response?.data}');
      throw Exception(
          'Gagal mengupdate todo: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Gagal mengupdate todo: $e');
    }
  }

  Future<TodoModel> toggleTodoCompletion(String id) async {
    try {
      print('[TodoService] Toggling todo $id');

      final response = await _dio.patch('/todos/$id/toggle');

      print('[TodoService] Toggle response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return TodoModel.fromJson(response.data);
      } else {
        throw Exception('Gagal toggle todo (status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[TodoService] Toggle error: ${e.response?.data}');
      throw Exception('Gagal toggle todo: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Gagal toggle todo: $e');
    }
  }

  Future<bool> deleteTodo(String id) async {
    try {
      print('[TodoService] Deleting todo $id');

      final response = await _dio.delete('/todos/$id');

      print('[TodoService] Delete response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.data['success'] ?? true;
      } else {
        throw Exception(
            'Gagal menghapus todo (status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[TodoService] Delete error: ${e.response?.data}');
      throw Exception('Gagal menghapus todo: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Gagal menghapus todo: $e');
    }
  }
}
