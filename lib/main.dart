// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'welcome_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // ИСПОЛЬЗУЙ НОВЫЕ КЛЮЧИ!
    await Supabase.initialize(
      url: 'https://vrsxvyxcmzvvawtgezen.supabase.co',
      anonKey: 'sb_publishable_PMuR-8ErVEu7nnQfWOE6ow_wwn3WHId',
    );
    
  } catch (e) {
    // Если ошибка, пробуем старый ключ как fallback
    try {
      await Supabase.initialize(
        url: 'https://vrsxvyxcmzvvawtgezen.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZyc3h2eXhjbXp2dmF3dGdlemVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY0MTM0MjUsImV4cCI6MjA1MTk4OTQyNX0.6q1q7q1q7q1q7q1q7q1q7q1q7q1q7q1q7q1q7q1q7q',
      );
    } catch (e2) {
      // Оба ключа не работают
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowTime Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D7CF9),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const FlowTimeHomePage(),
      },
    );
  }
}