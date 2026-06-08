import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isChecking = true;
  bool get isChecking => _isChecking;

  String? _token;
  String? get token => _token;

  User? _user;
  User? get user => _user;

  AuthProvider() {
    ApiClient.onUnauthorized = () {
      logout();
    };
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        _token = response.data['token'];
        await _storage.write(key: 'token', value: _token);

        // Store user data from login response
        if (response.data['user'] != null) {
          _user = User.fromJson(response.data['user']);
        }

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
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    _isChecking = true;
    notifyListeners();

    _token = await _storage.read(key: 'token');
    if (_token != null) {
      try {
        // Fetch user profile to validate the token
        final response = await _apiClient.dio.get('/auth/me');
        if (response.statusCode == 200) {
          _user = User.fromJson(response.data);
        } else {
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
    _isChecking = false;
    notifyListeners();
  }
}
