import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/announcement.dart';

class AnnouncementProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Announcement> _announcements = [];
  bool _isLoading = false;

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/announcements');
      if (response.statusCode == 200) {
        _announcements = (response.data as List)
            .map((e) => Announcement.fromJson(e))
            .toList();
      }
    } on DioException catch (e) {
      debugPrint('Fetch announcements error: ${e.message}');
    } catch (e) {
      debugPrint('Fetch announcements error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addAnnouncement(Announcement announcement) async {
    try {
      final response = await _apiClient.dio.post(
        '/announcements',
        data: announcement.toJson(),
      );
      if (response.statusCode == 201) {
        await fetchAnnouncements();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Add announcement error: ${e.message}');
    } catch (e) {
      debugPrint('Add announcement error: $e');
    }
    return false;
  }

  Future<bool> deleteAnnouncement(int id) async {
    try {
      final response = await _apiClient.dio.delete('/announcements/$id');
      if (response.statusCode == 200) {
        await fetchAnnouncements();
        return true;
      }
    } catch (e) {
      debugPrint('Delete announcement error: $e');
    }
    return false;
  }
}
