import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import '../core/theme.dart';

class RoomInfoScreen extends StatefulWidget {
  const RoomInfoScreen({super.key});

  @override
  State<RoomInfoScreen> createState() => _RoomInfoScreenState();
}

class _RoomInfoScreenState extends State<RoomInfoScreen> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _roomInfo;
  Map<String, dynamic>? _boardingHouseInfo;
  Map<String, dynamic>? _tenantInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoomData();
  }

  Future<void> _loadRoomData() async {
    setState(() => _isLoading = true);
    try {
      final tenantRes = await _apiClient.dio.get('/tenants');
      if (tenantRes.statusCode == 200 && tenantRes.data is List && (tenantRes.data as List).isNotEmpty) {
        final tenantData = tenantRes.data[0];
        setState(() {
          _tenantInfo = tenantData;
          if (tenantData['room'] != null) {
            _roomInfo = tenantData['room'];
          }
        });

        if (_roomInfo != null && _roomInfo!['boarding_house_id'] != null) {
          try {
            final bhRes = await _apiClient.dio.get('/boarding-houses/${_roomInfo!['boarding_house_id']}');
            if (bhRes.statusCode == 200) {
              setState(() => _boardingHouseInfo = bhRes.data);
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Error loading room data: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Image.asset(
                'assets/RUMA LOGO 1.png',
                height: 32,
                color: AppTheme.darkOlive,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('RUMA', style: TextStyle(fontWeight: FontWeight.bold));
                },
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRoomData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kamar Saya',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 20),

                    // Room Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.darkOlive,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightBeige.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.bed, color: AppTheme.lightBeige, size: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kamar ${_roomInfo?['room_number'] ?? '-'}',
                                      style: const TextStyle(
                                        color: AppTheme.lightBeige,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _boardingHouseInfo?['name'] ?? 'Kos',
                                      style: TextStyle(
                                        color: AppTheme.lightBeige.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (_roomInfo?['status'] == 'occupied')
                                  ? AppTheme.statusGreenBg
                                  : AppTheme.statusRedBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (_roomInfo?['status'] == 'occupied') ? 'Ditempati' : (_roomInfo?['status'] ?? '-'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Details
                    _buildDetailCard(
                      context,
                      title: 'Detail Kamar',
                      items: [
                        _DetailItem(
                          icon: Icons.tag,
                          label: 'Nomor Kamar',
                          value: _roomInfo?['room_number'] ?? '-',
                        ),
                        _DetailItem(
                          icon: Icons.attach_money,
                          label: 'Harga/Bulan',
                          value: _roomInfo?['price'] != null
                              ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                                  .format(_roomInfo!['price'])
                              : '-',
                        ),
                        _DetailItem(
                          icon: Icons.info_outline,
                          label: 'Status',
                          value: _roomInfo?['status'] ?? '-',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildDetailCard(
                      context,
                      title: 'Info Kos',
                      items: [
                        _DetailItem(
                          icon: Icons.home,
                          label: 'Nama Kos',
                          value: _boardingHouseInfo?['name'] ?? '-',
                        ),
                        _DetailItem(
                          icon: Icons.location_on,
                          label: 'Alamat',
                          value: _boardingHouseInfo?['address'] ?? '-',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildDetailCard(
                      context,
                      title: 'Waktu Sewa',
                      items: [
                        _DetailItem(
                          icon: Icons.login,
                          label: 'Check-in',
                          value: _tenantInfo?['check_in_date'] != null
                              ? DateFormat('dd MMMM yyyy').format(DateTime.parse(_tenantInfo!['check_in_date']))
                              : '-',
                        ),
                        _DetailItem(
                          icon: Icons.logout,
                          label: 'Check-out',
                          value: _tenantInfo?['check_out_date'] != null &&
                                  _tenantInfo!['check_out_date'] != '0001-01-01T00:00:00Z'
                              ? DateFormat('dd MMMM yyyy').format(DateTime.parse(_tenantInfo!['check_out_date']))
                              : 'Belum ditentukan',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailCard(BuildContext context,
      {required String title, required List<_DetailItem> items}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBeige,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, size: 18, color: AppTheme.darkOlive),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  const _DetailItem({required this.icon, required this.label, required this.value});
}
