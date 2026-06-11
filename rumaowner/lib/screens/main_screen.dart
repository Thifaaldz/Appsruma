import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/owner_widgets.dart';
import 'announcement_screen.dart';
import 'complaint_screen.dart';
import 'expense_form_screen.dart';
import 'finance_screen.dart';
import 'home_screen.dart';
import 'payment_bill_screen.dart';
import 'profile_screen.dart';
import 'room_screen.dart';
import 'tenant_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _navigateTo(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        onOpenTenants: () => _navigateTo(1),
        onOpenRooms: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RoomScreen()),
          );
        },
        onOpenComplaints: () => _navigateTo(3),
        onOpenPayments: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PaymentBillScreen()),
          );
        },
        onOpenFinance: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FinanceScreen()),
          );
        },
        onOpenExpense: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
          );
        },
        onOpenKosList: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RoomScreen()),
          );
        },
        onOpenVacantRooms: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const RoomScreen(filterVacant: true),
            ),
          );
        },
      ),
      const TenantScreen(),
      const AnnouncementScreen(),
      const ComplaintScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.lightBeige,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: OwnerBottomNav(
        currentIndex: _selectedIndex,
        onTap: _navigateTo,
      ),
    );
  }
}
