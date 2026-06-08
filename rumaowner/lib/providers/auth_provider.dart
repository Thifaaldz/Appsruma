import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/user_profile.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isChecking = true;
  bool get isChecking => _isChecking;

  String? _token;
  String? get token => _token;

  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;

  String? _profileError;
  String? get profileError => _profileError;

  AuthProvider() {
    ApiClient.onUnauthorized = () {
      logout();
    };
  }

  String _profileImageCacheKey(int userId) => 'profile_image_$userId';

  Future<UserProfile> _withCachedProfileImage(UserProfile user) async {
    if (user.profileImage.isNotEmpty) {
      await _storage.write(
        key: _profileImageCacheKey(user.id),
        value: user.profileImage,
      );
      return user;
    }

    final cachedImage = await _storage.read(
      key: _profileImageCacheKey(user.id),
    );
    if (cachedImage == null || cachedImage.isEmpty) {
      return user;
    }

    return user.copyWith(profileImage: cachedImage);
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
        final userData = response.data['user'];
        if (userData is Map) {
          _currentUser = await _withCachedProfileImage(
            UserProfile.fromJson(Map<String, dynamic>.from(userData)),
          );
          _profileError = null;
        } else {
          await fetchProfile();
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
    _currentUser = null;
    _profileError = null;
    notifyListeners();
  }

  Future<bool> fetchProfile() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');
      if (response.statusCode == 200) {
        _currentUser = await _withCachedProfileImage(
          UserProfile.fromJson(Map<String, dynamic>.from(response.data)),
        );
        _profileError = null;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = e.response?.data is Map
          ? e.response?.data['error']
          : e.message;
      _profileError = status == null
          ? 'Gagal membaca profile: $message'
          : 'Gagal membaca profile ($status): $message';
      notifyListeners();
      print(_profileError);
    } catch (e) {
      _profileError = 'Gagal membaca profile: $e';
      notifyListeners();
      print(e);
    }
    return false;
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String gender,
    required String birthDate,
    required String address,
    required String profileImage,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.put(
        '/auth/me',
        data: {
          'name': name,
          'phone': phone,
          'gender': gender,
          'birth_date': birthDate,
          'address': address,
          'profile_image': profileImage,
        },
      );
      if (response.statusCode == 200) {
        final updatedUser = UserProfile.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        final profile =
            updatedUser.profileImage.isNotEmpty || profileImage.isEmpty
            ? updatedUser
            : updatedUser.copyWith(profileImage: profileImage);
        _currentUser = await _withCachedProfileImage(profile);
        _profileError = null;
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

  Future<void> checkAuth() async {
    _isChecking = true;
    notifyListeners();

    _token = await _storage.read(key: 'token');
    if (_token != null) {
      try {
        final response = await _apiClient.dio.get('/rooms');
        if (response.statusCode != 200) {
          await logout();
        } else {
          await fetchProfile();
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
