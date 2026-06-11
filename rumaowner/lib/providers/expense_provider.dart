import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  double get totalExpenses =>
      _expenses.fold<double>(0, (sum, e) => sum + e.amount);

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/expenses');
      if (response.statusCode == 200) {
        _expenses = (response.data as List)
            .map((e) => Expense.fromJson(e))
            .toList();
      }
    } on DioException catch (e) {
      debugPrint('Fetch expenses error: ${e.message}');
    } catch (e) {
      debugPrint('Fetch expenses error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addExpense(Expense expense) async {
    try {
      final response = await _apiClient.dio.post(
        '/expenses',
        data: expense.toJson(),
      );
      if (response.statusCode == 201) {
        await fetchExpenses();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Add expense error: ${e.message}');
    } catch (e) {
      debugPrint('Add expense error: $e');
    }
    return false;
  }

  Future<bool> deleteExpense(int id) async {
    try {
      final response = await _apiClient.dio.delete('/expenses/$id');
      if (response.statusCode == 200) {
        await fetchExpenses();
        return true;
      }
    } catch (e) {
      debugPrint('Delete expense error: $e');
    }
    return false;
  }
}
