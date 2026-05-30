import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/tenant.dart';

class TenantProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Tenant> _tenants = [];
  List<Map<String, dynamic>> _tenantUsers = [];
  bool _isLoading = false;

  List<Tenant> get tenants => _tenants;
  List<Map<String, dynamic>> get tenantUsers => _tenantUsers;
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
      print('Fetch tenants error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTenantUsers() async {
    try {
      final response = await _apiClient.dio.get('/auth/tenants');
      if (response.statusCode == 200) {
        _tenantUsers = List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      print('Fetch tenant users error: $e');
    }
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
      print('Add tenant error: $e');
    }
    return false;
  }
}
