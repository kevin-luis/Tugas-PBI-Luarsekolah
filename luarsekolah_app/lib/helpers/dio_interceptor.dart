import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('╔══════════════════════════════════════════════════════');
    print('║ REQUEST');
    print('╠══════════════════════════════════════════════════════');
    print('║ ${options.method} ${options.uri}');
    print('║ Headers: ${options.headers}');
    if (options.data != null) {
      print('║ Body: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      print('║ Query: ${options.queryParameters}');
    }
    print('╚══════════════════════════════════════════════════════');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('╔══════════════════════════════════════════════════════');
    print('║ RESPONSE');
    print('╠══════════════════════════════════════════════════════');
    print('║ Status: ${response.statusCode}');
    print('║ Data: ${response.data}');
    print('╚══════════════════════════════════════════════════════');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('╔══════════════════════════════════════════════════════');
    print('║ ERROR');
    print('╠══════════════════════════════════════════════════════');
    print('║ ${err.type}');
    print('║ ${err.message}');
    if (err.response != null) {
      print('║ Status: ${err.response?.statusCode}');
      print('║ Data: ${err.response?.data}');
    }
    print('╚══════════════════════════════════════════════════════');
    super.onError(err, handler);
  }
}