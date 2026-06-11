import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/tenant_widgets.dart';
import 'complaint_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'payment_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        onPayNow: () => _navigateTo(1),
        onOpenHistory: () => _navigateTo(3),
        onOpenComplaint: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ComplaintScreen()),
          );
        },
        onOpenNotifications: () => _navigateTo(2),
      ),
      const PaymentScreen(),
      const NotificationScreen(),
      const HistoryScreen(),
      ProfileScreen(
        onOpenComplaint: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ComplaintScreen()));
        },
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.lightBeige,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: RumaBottomNav(
        currentIndex: _selectedIndex,
        onTap: _navigateTo,
      ),
    );
  }
}
