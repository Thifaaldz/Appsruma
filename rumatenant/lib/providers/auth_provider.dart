import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _token;
  String? get token => _token;

  AuthProvider() {
    ApiClient.onUnauthorized = () {
      logout();
    };
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        _token = response.data['token'];
        await _storage.write(key: 'token', value: _token);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    _token = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    _token = await _storage.read(key: 'token');
    if (_token != null) {
      try {
        final response = await _apiClient.dio.get('/rooms');
        if (response.statusCode != 200) {
          await logout();
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          await logout();
        }
      } catch (e) {
        print(e);
      }
    }
    notifyListeners();
  }
}
