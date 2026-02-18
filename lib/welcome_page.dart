// lib/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Логотип и заголовок
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5D7CF9), Color(0xFF7B6CF2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5D7CF9).withAlpha(76),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.timer,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'FlowTime Pro',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2C3E50),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Управляй временем с умом',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Иллюстрация
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insights,
                        size: 80,
                        color: const Color(0xFF5D7CF9).withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Аналитика времени\nи рекомендации',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Кнопки действий
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D7CF9),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Войти',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5D7CF9),
                        side: const BorderSide(color: Color(0xFF5D7CF9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Создать аккаунт',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Текст с соглашением
              Text(
                'Продолжая, вы соглашаетесь с условиями использования\nи политикой конфиденциальности',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}