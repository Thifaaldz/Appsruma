import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/tenant.dart';

class TenantProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Tenant> _tenants = [];
  List<Map<String, dynamic>> _tenantUsers = [];
  bool _isLoading = false;
  int? _lastBoardingHouseId;
  int? _activeBoardingHouseId;
  int? _tenantUsersBoardingHouseId;

  List<Tenant> get tenants {
    final scopeId = _activeBoardingHouseId ?? _lastBoardingHouseId;
    if (scopeId == null) return _tenants;
    return _tenants
        .where((tenant) => tenant.boardingHouseId == scopeId)
        .toList();
  }

  List<Map<String, dynamic>> get tenantUsers {
    final scopeId = _activeBoardingHouseId ?? _lastBoardingHouseId;
    if (scopeId == null || _tenantUsersBoardingHouseId != scopeId) {
      return [];
    }
    return _tenantUsers;
  }

  bool get isLoading => _isLoading;
  int? get activeBoardingHouseId => _activeBoardingHouseId;
  int? get tenantUsersBoardingHouseId => _tenantUsersBoardingHouseId;

  void setActiveBoardingHouse(int? boardingHouseId) {
    _activeBoardingHouseId = boardingHouseId;
    _lastBoardingHouseId = boardingHouseId;
    if (boardingHouseId == null) {
      _tenants = [];
      _tenantUsers = [];
      _tenantUsersBoardingHouseId = null;
    } else {
      _tenants = _tenants
          .where((tenant) => tenant.boardingHouseId == boardingHouseId)
          .toList();
      _tenantUsers = [];
      _tenantUsersBoardingHouseId = null;
    }
    notifyListeners();
  }

  Future<void> fetchTenants({int? boardingHouseId}) async {
    _isLoading = true;
    final scopedBoardingHouseId = boardingHouseId ?? _activeBoardingHouseId;
    if (scopedBoardingHouseId != null) {
      _activeBoardingHouseId = scopedBoardingHouseId;
    }
    _lastBoardingHouseId = scopedBoardingHouseId;
    notifyListeners();

    try {
      final params = scopedBoardingHouseId != null
          ? {'boarding_house_id': scopedBoardingHouseId.toString()}
          : null;
      final response = await _apiClient.dio.get(
        '/tenants',
        queryParameters: params,
      );
      if (response.statusCode == 200) {
        final fetchedTenants = (response.data as List)
            .map((e) => Tenant.fromJson(e))
            .toList();
        _tenants = scopedBoardingHouseId == null
            ? fetchedTenants
            : fetchedTenants
                  .where(
                    (tenant) => tenant.boardingHouseId == scopedBoardingHouseId,
                  )
                  .toList();
      }
    } catch (e) {
      print('Fetch tenants error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTenantUsers({int? boardingHouseId}) async {
    try {
      final scopedBoardingHouseId = boardingHouseId ?? _activeBoardingHouseId;
      if (scopedBoardingHouseId == null) {
        _tenantUsers = [];
        _tenantUsersBoardingHouseId = null;
        notifyListeners();
        return;
      }
      _activeBoardingHouseId = scopedBoardingHouseId;
      _lastBoardingHouseId = scopedBoardingHouseId;
      final response = await _apiClient.dio.get(
        '/auth/tenants',
        queryParameters: {
          'boarding_house_id': scopedBoardingHouseId.toString(),
        },
      );
      if (response.statusCode == 200) {
        _tenantUsers = List<Map<String, dynamic>>.from(response.data);
        _tenantUsersBoardingHouseId = scopedBoardingHouseId;
      }
    } catch (e) {
      _tenantUsers = [];
      _tenantUsersBoardingHouseId = null;
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
