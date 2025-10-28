import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';

class ImageUploadService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://ls-lms.zoidify.my.id/api',
      headers: {
        'Authorization': 'Bearer YOUR_TOKEN_HERE',
      },
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  /// Upload image ke server dan return URL
  /// Sesuaikan endpoint dengan API Anda
  static Future<Map<String, dynamic>> uploadImage(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!file.existsSync()) {
        return {
          'success': false,
          'message': 'File tidak ditemukan',
        };
      }

      // Get file name
      final fileName = file.path.split('/').last;
      
      // Create FormData
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      // Upload ke endpoint (sesuaikan dengan API Anda)
      final response = await _dio.post(
        '/upload/image', // Ganti dengan endpoint upload Anda
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Sesuaikan dengan response structure API Anda
        final imageUrl = response.data['url'] ?? response.data['data']?['url'];
        
        return {
          'success': true,
          'url': imageUrl,
        };
      }

      return {
        'success': false,
        'message': 'Upload gagal',
      };
    } on DioException catch (e) {
      print('Error uploading image: ${e.message}');
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

  /// Convert image to Base64 (alternatif jika API menerima base64)
  static Future<String?> imageToBase64(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      print('Error converting to base64: $e');
      return null;
    }
  }
}