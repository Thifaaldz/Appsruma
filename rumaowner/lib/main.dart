import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/room_provider.dart';
import 'providers/tenant_provider.dart';
import 'providers/boarding_house_provider.dart';
import 'providers/complaint_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'core/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => TenantProvider()),
        ChangeNotifierProvider(create: (_) => BoardingHouseProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
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
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.token != null) {
            return const MainScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
