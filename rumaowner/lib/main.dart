import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/auth_provider.dart';
import 'providers/room_provider.dart';
import 'providers/tenant_provider.dart';
import 'providers/boarding_house_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/announcement_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/boarding_house_selection_screen.dart';
import 'screens/welcome_screen.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => TenantProvider()),
        ChangeNotifierProvider(create: (_) => BoardingHouseProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kos Owner',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const StartupGate(),
    );
  }
}

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool _allowTransition = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        setState(() => _allowTransition = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final selectedBh = context.watch<BoardingHouseProvider>().selectedBoardingHouse;
    final showTarget = _allowTransition && !auth.isChecking;

    Widget targetScreen;
    String targetKey;
    if (auth.token != null) {
      if (selectedBh != null) {
        targetScreen = const MainScreen();
        targetKey = 'main';
      } else {
        targetScreen = const BoardingHouseSelectionScreen();
        targetKey = 'select_bh';
      }
    } else {
      targetScreen = const WelcomeScreen();
      targetKey = 'welcome';
    }

    final child = showTarget ? targetScreen : const SplashScreen();
    final currentKey = showTarget ? targetKey : 'splash';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 550),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<String>(currentKey),
        child: child,
      ),
    );
  }
}

