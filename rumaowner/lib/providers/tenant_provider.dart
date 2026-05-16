import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/tenant.dart';

class TenantProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Tenant> _tenants = [];
  bool _isLoading = false;

  List<Tenant> get tenants => _tenants;
  bool get isLoading => _isLoading;

  Future<void> fetchTenants() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/tenants');
      if (response.statusCode == 200) {
        _tenants = (response.data as List).map((e) => Tenant.fromJson(e)).toList();
      }
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addTenant(Tenant tenant) async {
    try {
      final response = await _apiClient.dio.post('/tenants', data: tenant.toJson());
      if (response.statusCode == 201) {
        await fetchTenants();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
