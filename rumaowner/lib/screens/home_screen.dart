import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/boarding_house_provider.dart';
import '../models/boarding_house.dart';
import '../core/theme.dart';
import 'property_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<BoardingHouseProvider>().fetchBoardingHouses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bhProvider = context.watch<BoardingHouseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'assets/RUMA LOGO 1.png',
            height: 32,
            color: AppTheme.darkOlive,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, size: 32),
            onSelected: (value) async {
              if (value == 'logout') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Keluar'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Keluar'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppTheme.textDark),
                    SizedBox(width: 8),
                    Text('Keluar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: bhProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: bhProvider.boardingHouses.length + 1, // +1 for "Tambah Kosan"
              itemBuilder: (context, index) {
                if (index == bhProvider.boardingHouses.length) {
                  return _buildAddButton(context);
                }
                final bh = bhProvider.boardingHouses[index];
                return _buildPropertyCard(context, bh);
              },
            ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, BoardingHouse bh) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: bh.imageUrl.isNotEmpty
                  ? Image.network(
                      bh.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.home, size: 48, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.home, size: 48, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            bh.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge('${bh.totalRooms} Kamar', AppTheme.lightBeige, AppTheme.textDark),
              _buildBadge('${bh.vacantRooms} Kosong', AppTheme.statusRedBg, AppTheme.statusRedText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PropertyDetailScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkOlive,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: AppTheme.lightBeige, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Tambah Kosan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
