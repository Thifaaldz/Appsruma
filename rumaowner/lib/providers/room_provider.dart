import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/room.dart';

class RoomProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Room> _rooms = [];
  bool _isLoading = false;
  int? _lastBoardingHouseId;

  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;

  Future<void> fetchRooms({int? boardingHouseId}) async {
    _isLoading = true;
    _lastBoardingHouseId = boardingHouseId;
    notifyListeners();

    try {
      final params = boardingHouseId != null
          ? {'boarding_house_id': boardingHouseId.toString()}
          : null;
      final response = await _apiClient.dio.get('/rooms',
          queryParameters: params);
      if (response.statusCode == 200) {
        _rooms = (response.data as List).map((e) => Room.fromJson(e)).toList();
      }
    } on DioException catch (e) {
      debugPrint('Fetch rooms error: ${_describeDioError(e)}');
    } catch (e) {
      debugPrint('Fetch rooms error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addRoom(Room room) async {
    try {
      final response = await _apiClient.dio.post('/rooms', data: room.toJson());
      if (response.statusCode == 201) {
        await fetchRooms(boardingHouseId: _lastBoardingHouseId);
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Add room error: ${_describeDioError(e)}');
    } catch (e) {
      debugPrint('Add room error: $e');
    }
    return false;
  }

  Future<bool> updateRoom(int id, Room room) async {
    try {
      final response = await _apiClient.dio.put(
        '/rooms/$id',
        data: room.toJson(),
      );
      if (response.statusCode == 200) {
        await fetchRooms(boardingHouseId: _lastBoardingHouseId);
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Update room error: ${_describeDioError(e)}');
    } catch (e) {
      debugPrint('Update room error: $e');
    }
    return false;
  }

  Future<bool> deleteRoom(int id) async {
    try {
      final response = await _apiClient.dio.delete('/rooms/$id');
      if (response.statusCode == 200) {
        await fetchRooms(boardingHouseId: _lastBoardingHouseId);
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Delete room error: ${_describeDioError(e)}');
    } catch (e) {
      debugPrint('Delete room error: $e');
    }
    return false;
  }

  String _describeDioError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    return 'status=$status data=$data message=${e.message}';
  }
}
