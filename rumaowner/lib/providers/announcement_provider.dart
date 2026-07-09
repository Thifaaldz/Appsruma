import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/announcement.dart';

class AnnouncementProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Announcement> _announcements = [];
  bool _isLoading = false;
  int? _lastBoardingHouseId;

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;

  Future<void> fetchAnnouncements({int? boardingHouseId}) async {
    _isLoading = true;
    _lastBoardingHouseId = boardingHouseId;
    notifyListeners();

    try {
      final params = boardingHouseId != null
          ? {'boarding_house_id': boardingHouseId.toString()}
          : null;
      final response = await _apiClient.dio.get(
        '/announcements',
        queryParameters: params,
      );
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

  Future<bool> addAnnouncement(
    Announcement announcement, {
    int? boardingHouseId,
  }) async {
    try {
      final data = announcement.toJson();
      if (announcement.targetType == 'user' &&
          announcement.targetUserId == null) {
        debugPrint('Add announcement error: target_user_id is required');
        return false;
      }
      final response = await _apiClient.dio.post('/announcements', data: data);
      if (response.statusCode == 201) {
        if (announcement.targetType == 'user') {
          final returnedTargetUserId = response.data is Map
              ? response.data['target_user_id']
              : null;
          if (returnedTargetUserId == null) {
            debugPrint(
              'Add announcement error: backend did not save target_user_id',
            );
            return false;
          }
        }
        await fetchAnnouncements(
          boardingHouseId: boardingHouseId ?? _lastBoardingHouseId,
        );
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Add announcement error: ${e.message}');
    } catch (e) {
      debugPrint('Add announcement error: $e');
    }
    return false;
  }

  Future<bool> deleteAnnouncement(int id, {int? boardingHouseId}) async {
    try {
      final selectedId = boardingHouseId ?? _lastBoardingHouseId;
      final params = selectedId != null
          ? {'boarding_house_id': selectedId.toString()}
          : null;
      final response = await _apiClient.dio.delete(
        '/announcements/$id',
        queryParameters: params,
      );
      if (response.statusCode == 200) {
        await fetchAnnouncements(boardingHouseId: selectedId);
        return true;
      }
    } catch (e) {
      debugPrint('Delete announcement error: $e');
    }
    return false;
  }
}
