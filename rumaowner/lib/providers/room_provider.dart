import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/room.dart';

class RoomProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Room> _rooms = [];
  bool _isLoading = false;

  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;

  Future<void> fetchRooms() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/rooms');
      if (response.statusCode == 200) {
        _rooms = (response.data as List).map((e) => Room.fromJson(e)).toList();
      }
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addRoom(Room room) async {
    try {
      final response = await _apiClient.dio.post('/rooms', data: room.toJson());
      if (response.statusCode == 201) {
        await fetchRooms();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> updateRoom(int id, Room room) async {
    try {
      final response = await _apiClient.dio.put('/rooms/$id', data: room.toJson());
      if (response.statusCode == 200) {
        await fetchRooms();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> deleteRoom(int id) async {
    try {
      final response = await _apiClient.dio.delete('/rooms/$id');
      if (response.statusCode == 200) {
        await fetchRooms();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
