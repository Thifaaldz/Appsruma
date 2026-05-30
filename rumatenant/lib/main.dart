import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/complaint_provider.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
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
      title: 'RUMA Penghuni',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
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
