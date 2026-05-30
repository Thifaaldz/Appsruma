import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static void Function()? onUnauthorized;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.110.39:8080/api', // LAN IP for physical device
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  final _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        if (e.response?.statusCode == 401) {
          onUnauthorized?.call();
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
