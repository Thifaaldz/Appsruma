import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/boarding_house.dart';

class BoardingHouseProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<BoardingHouse> _boardingHouses = [];
  bool _isLoading = false;
  String? _lastError;

  List<BoardingHouse> get boardingHouses => _boardingHouses;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<void> fetchBoardingHouses() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/boarding-houses');
      if (response.statusCode == 200) {
        _boardingHouses = (response.data as List)
            .map((e) => BoardingHouse.fromJson(e))
            .toList();
      }
    } on DioException catch (e) {
      _lastError = _describeDioError(e);
      debugPrint('Fetch boarding houses error: $_lastError');
    } catch (e) {
      _lastError = '$e';
      debugPrint('Fetch boarding houses error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addBoardingHouse(BoardingHouse bh) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post(
        '/boarding-houses',
        data: bh.toJson(),
      );
      if (response.statusCode == 201) {
        await fetchBoardingHouses();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _lastError = 'Status ${response.statusCode}: ${response.data}';
    } on DioException catch (e) {
      _lastError = _describeDioError(e);
      debugPrint('Add boarding house error: $_lastError');
    } catch (e) {
      _lastError = '$e';
      debugPrint('Add boarding house error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateBoardingHouse(BoardingHouse bh) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.put(
        '/boarding-houses/${bh.id}',
        data: bh.toJson(),
      );
      if (response.statusCode == 200) {
        await fetchBoardingHouses();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _lastError = 'Status ${response.statusCode}: ${response.data}';
    } on DioException catch (e) {
      _lastError = _describeDioError(e);
      debugPrint('Update boarding house error: $_lastError');
    } catch (e) {
      _lastError = '$e';
      debugPrint('Update boarding house error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteBoardingHouse(int id) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.delete('/boarding-houses/$id');
      if (response.statusCode == 200) {
        await fetchBoardingHouses();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _lastError = 'Status ${response.statusCode}: ${response.data}';
    } on DioException catch (e) {
      _lastError = _describeDioError(e);
      debugPrint('Delete boarding house error: $_lastError');
    } catch (e) {
      _lastError = '$e';
      debugPrint('Delete boarding house error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  String _describeDioError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map) {
      final detail = data['detail'];
      final error = data['error'];
      if (detail != null) return '$status: $error ($detail)';
      if (error != null) return '$status: $error';
    }
    return 'status=$status data=$data message=${e.message}';
  }
}
