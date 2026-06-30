import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/tenant.dart';

class TenantProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Tenant> _tenants = [];
  List<Map<String, dynamic>> _tenantUsers = [];
  bool _isLoading = false;
  int? _lastBoardingHouseId;

  List<Tenant> get tenants => _tenants;
  List<Map<String, dynamic>> get tenantUsers => _tenantUsers;
  bool get isLoading => _isLoading;

  Future<void> fetchTenants({int? boardingHouseId}) async {
    _isLoading = true;
    _lastBoardingHouseId = boardingHouseId;
    notifyListeners();

    try {
      final params = boardingHouseId != null
          ? {'boarding_house_id': boardingHouseId.toString()}
          : null;
      final response = await _apiClient.dio.get('/tenants',
          queryParameters: params);
      if (response.statusCode == 200) {
        _tenants = (response.data as List)
            .map((e) => Tenant.fromJson(e))
            .toList();
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
      final response = await _apiClient.dio.post(
        '/tenants',
        data: tenant.toJson(),
      );
      if (response.statusCode == 201) {
        await fetchTenants(boardingHouseId: _lastBoardingHouseId);
        return true;
      }
    } catch (e) {
      print('Add tenant error: $e');
    }
    return false;
  }
}
