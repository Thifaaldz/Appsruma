import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/boarding_house.dart';

class BoardingHouseProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<BoardingHouse> _boardingHouses = [];
  bool _isLoading = false;

  List<BoardingHouse> get boardingHouses => _boardingHouses;
  bool get isLoading => _isLoading;

  Future<void> fetchBoardingHouses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/boarding-houses');
      if (response.statusCode == 200) {
        _boardingHouses = (response.data as List)
            .map((e) => BoardingHouse.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Fetch boarding houses error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addBoardingHouse(BoardingHouse bh) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post('/boarding-houses', data: bh.toJson());
      if (response.statusCode == 201) {
        await fetchBoardingHouses();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Add boarding house error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
