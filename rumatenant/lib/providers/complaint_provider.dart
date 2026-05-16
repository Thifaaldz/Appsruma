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
        _complaints = (response.data as List).map((e) => Complaint.fromJson(e)).toList();
      }
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addComplaint(Complaint complaint) async {
    try {
      final response = await _apiClient.dio.post('/complaints', data: complaint.toJson());
      if (response.statusCode == 201) {
        await fetchComplaints();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
