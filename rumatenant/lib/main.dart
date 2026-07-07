import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/tenant_provider.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => TenantProvider()),
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
      title: 'RUMA Tenant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
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
  bool _dataFetched = false;

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
    final showTarget = _allowTransition && !auth.isChecking;

    // Once auth is verified and user is logged in, fetch tenant data
    if (showTarget && auth.token != null && !_dataFetched) {
      _dataFetched = true;
      Future.microtask(() {
        if (mounted) {
          context.read<TenantProvider>().fetchAll();
        }
      });
    }

    // If user logged out, reset
    if (auth.token == null && _dataFetched) {
      _dataFetched = false;
    }

    final child = showTarget
        ? (auth.token != null ? const MainScreen() : const WelcomeScreen())
        : const SplashScreen();

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
        key: ValueKey<String>(
          showTarget ? (auth.token != null ? 'main' : 'welcome') : 'splash',
        ),
        child: child,
      ),
    );
  }
}
