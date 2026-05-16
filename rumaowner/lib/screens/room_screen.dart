import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../models/room.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RoomProvider>().fetchRooms());
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showRoomDialog(context),
          ),
        ],
      ),
      body: roomProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: roomProvider.rooms.length,
              itemBuilder: (context, index) {
                final room = roomProvider.rooms[index];
                return ListTile(
                  title: Text('Room ${room.roomNumber}'),
                  subtitle: Text('Status: ${room.status} - Price: ${room.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showRoomDialog(context, room: room),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => roomProvider.deleteRoom(room.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showRoomDialog(BuildContext context, {Room? room}) {
    final numberController = TextEditingController(text: room?.roomNumber ?? '');
    final priceController = TextEditingController(text: room?.price.toString() ?? '');
    String status = room?.status ?? 'available';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(room == null ? 'Add Room' : 'Edit Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: numberController, decoration: const InputDecoration(labelText: 'Room Number')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
            DropdownButton<String>(
              value: status,
              items: ['available', 'occupied', 'maintenance'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => status = val!),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final newRoom = Room(
                id: room?.id ?? 0,
                boardingHouseId: 1, // Default for now
                roomNumber: numberController.text,
                price: double.parse(priceController.text),
                status: status,
              );
              bool success;
              if (room == null) {
                success = await context.read<RoomProvider>().addRoom(newRoom);
              } else {
                success = await context.read<RoomProvider>().updateRoom(room.id, newRoom);
              }
              if (success) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
