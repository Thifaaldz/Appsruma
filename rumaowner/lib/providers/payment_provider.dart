import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/payment.dart';

class PaymentProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Payment> _payments = [];
  bool _isLoading = false;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;

  Future<void> fetchPayments({int? boardingHouseId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final params = boardingHouseId != null
          ? {'boarding_house_id': boardingHouseId.toString()}
          : null;
      final response = await _apiClient.dio.get('/payments',
          queryParameters: params);
      if (response.statusCode == 200) {
        final list = response.data as List;
        _payments = list.map((e) => Payment.fromJson(e)).toList();
        // Sort by date descending (most recent first)
        _payments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      }
    } on DioException catch (e) {
      debugPrint('Fetch payments error: ${_describeDioError(e)}');
    } catch (e) {
      debugPrint('Fetch payments error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  String _describeDioError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    return 'status=$status data=$data message=${e.message}';
  }
}
