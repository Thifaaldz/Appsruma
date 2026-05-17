import 'package:flutter/material.dart';
import '../core/theme.dart';

class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({super.key});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _roomCountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''), // Empty, just back button and RUMA logo
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Image.asset(
                'assets/RUMA LOGO 1.png',
                height: 32,
                color: AppTheme.darkOlive,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://picsum.photos/600/300', // Mock photo
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField('Nama Kos', _nameController),
            const SizedBox(height: 16),
            _buildTextField('Alamat Kos', _addressController),
            const SizedBox(height: 16),
            _buildTextField('Jumlah Kamar', _roomCountController, keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Save logic
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(),
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
