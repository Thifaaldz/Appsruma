import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/complaint.dart';

class ComplaintProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Complaint> _complaints = [];
  bool _isLoading = false;
  int? _lastBoardingHouseId;

  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;

  Future<void> fetchComplaints({int? boardingHouseId}) async {
    _isLoading = true;
    _lastBoardingHouseId = boardingHouseId;
    notifyListeners();

    try {
      final params = boardingHouseId != null
          ? {'boarding_house_id': boardingHouseId.toString()}
          : null;
      final response = await _apiClient.dio.get('/complaints',
          queryParameters: params);
      if (response.statusCode == 200) {
        _complaints = (response.data as List)
            .map((e) => Complaint.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Fetch complaints error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateComplaintStatus(int id, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.put(
        '/complaints/$id',
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        await fetchComplaints(boardingHouseId: _lastBoardingHouseId);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Update complaint status error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
