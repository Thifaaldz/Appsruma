import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'property_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for properties
    final List<Map<String, dynamic>> properties = [
      {'name': 'Kosan Anggrek', 'total': 7, 'vacant': 3, 'image': 'https://picsum.photos/400/300'},
      {'name': 'Kosan Rajeg', 'total': 7, 'vacant': 3, 'image': 'https://picsum.photos/400/301'},
      {'name': 'Kosan Anggrek', 'total': 7, 'vacant': 3, 'image': 'https://picsum.photos/400/302'},
      {'name': 'Kosan Anggrek', 'total': 7, 'vacant': 3, 'image': 'https://picsum.photos/400/303'},
      {'name': 'Kosan Anggrek', 'total': 7, 'vacant': 3, 'image': 'https://picsum.photos/400/304'},
      {'name': 'Kosan Anggrek', 'total': 7, 'vacant': 3, 'image': 'https://picsum.photos/400/305'},
      {'name': 'Kosan Anggrek', 'total': 7, 'vacant': 3, 'image': 'https://picsum.photos/400/306'},
    ];

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
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32),
            onPressed: () {},
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: properties.length + 1, // +1 for "Tambah Kosan"
        itemBuilder: (context, index) {
          if (index == properties.length) {
            return _buildAddButton(context);
          }
          final property = properties[index];
          return _buildPropertyCard(context, property);
        },
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, Map<String, dynamic> property) {
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
              child: Image.network(
                property['image'],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            property['name'],
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge('${property['total']} Kamar', AppTheme.lightBeige, AppTheme.textDark),
              _buildBadge('${property['vacant']} Kosong', AppTheme.statusRedBg, AppTheme.statusRedText),
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
