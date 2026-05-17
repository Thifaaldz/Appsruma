import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'room_screen.dart';
import 'tenant_screen.dart';
import 'complaint_screen.dart';
import '../core/theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    TenantScreen(),
    RoomScreen(),
    ComplaintScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        color: AppTheme.darkOlive,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 0),
              _buildNavItem(Icons.people, 1),
              _buildNavItem(Icons.edit_document, 2),
              _buildNavItem(Icons.notifications_active, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightBeige : Colors.transparent,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.darkOlive : AppTheme.lightBeige,
          size: 28,
        ),
      ),
    );
  }
}
