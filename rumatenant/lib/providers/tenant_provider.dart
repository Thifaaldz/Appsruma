import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/tenant.dart';
import '../models/room.dart';
import '../models/boarding_house.dart';
import '../models/payment.dart';
import '../models/user.dart';

class TenantProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Tenant? _tenant;
  Tenant? get tenant => _tenant;

  Room? _room;
  Room? get room => _room;

  BoardingHouse? _boardingHouse;
  BoardingHouse? get boardingHouse => _boardingHouse;

  User? _user;
  User? get user => _user;

  List<Payment> _payments = [];
  List<Payment> get payments => _payments;

  /// Fetches all tenant data: user profile, tenant record, room, boarding house, payments
  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _fetchUserProfile(),
      _fetchTenantInfo(),
      _fetchBoardingHouse(),
      _fetchPayments(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch the logged-in user's profile
  Future<void> _fetchUserProfile() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');
      if (response.statusCode == 200) {
        _user = User.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('TenantProvider._fetchUserProfile error: $e');
    }
  }

  /// Fetch tenant record (includes nested user and room from backend preload)
  Future<void> _fetchTenantInfo() async {
    try {
      final response = await _apiClient.dio.get('/tenants');
      if (response.statusCode == 200) {
        final list = response.data as List;
        if (list.isNotEmpty) {
          _tenant = Tenant.fromJson(list.first);
          // Also extract room from the tenant's preloaded data
          if (_tenant?.room != null) {
            _room = _tenant!.room;
          }
        }
      }
    } catch (e) {
      debugPrint('TenantProvider._fetchTenantInfo error: $e');
    }
  }

  /// Fetch boarding house info
  Future<void> _fetchBoardingHouse() async {
    try {
      final response = await _apiClient.dio.get('/boarding-houses');
      if (response.statusCode == 200) {
        final list = response.data as List;
        if (list.isNotEmpty) {
          _boardingHouse = BoardingHouse.fromJson(list.first);
        }
      }
    } catch (e) {
      debugPrint('TenantProvider._fetchBoardingHouse error: $e');
    }
  }

  /// Fetch payment history
  Future<void> _fetchPayments() async {
    try {
      final response = await _apiClient.dio.get('/payments');
      if (response.statusCode == 200) {
        final list = response.data as List;
        _payments = list.map((e) => Payment.fromJson(e)).toList();
        // Sort by date descending (most recent first)
        _payments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      }
    } catch (e) {
      debugPrint('TenantProvider._fetchPayments error: $e');
    }
  }

  /// Get the current pending payment (if any)
  Payment? get pendingPayment {
    try {
      return _payments.firstWhere(
        (p) => p.status == 'pending',
      );
    } catch (_) {
      return null;
    }
  }

  /// Confirm/pay a pending payment (Manual confirmation fallback)
  Future<bool> confirmPayment(int paymentId) async {
    try {
      final response = await _apiClient.dio.put('/payments/$paymentId/confirm');
      if (response.statusCode == 200) {
        await _fetchPayments();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('TenantProvider.confirmPayment error: $e');
    }
    return false;
  }

  /// Request Snap token and redirect URL from Midtrans via Go backend
  Future<Map<String, dynamic>?> getMidtransSnapToken(int paymentId) async {
    try {
      final response = await _apiClient.dio.post('/payments/$paymentId/snap-token');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('TenantProvider.getMidtransSnapToken error: $e');
    }
    return null;
  }

  /// Manually trigger check status of Midtrans order on backend
  Future<bool> checkPaymentStatus(String orderId) async {
    try {
      final response = await _apiClient.dio.get('/payments/status/$orderId');
      if (response.statusCode == 200) {
        await _fetchPayments();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('TenantProvider.checkPaymentStatus error: $e');
    }
    return false;
  }

  /// Refresh all data
  Future<void> refresh() async {
    await fetchAll();
  }

  /// Clear all data (on logout)
  void clear() {
    _tenant = null;
    _room = null;
    _boardingHouse = null;
    _user = null;
    _payments = [];
    notifyListeners();
  }
}
