import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/complaint.dart';

class ComplaintProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Complaint> _complaints = [];
  bool _isLoading = false;

  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;

  Future<void> fetchComplaints() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/complaints');
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
        await fetchComplaints();
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
