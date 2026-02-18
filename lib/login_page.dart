// lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _goToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar('Заполните все поля');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FlowTimeHomePage()),
        );
      } else {
        setState(() {
          _errorMessage = 'Неверный email или пароль';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка входа: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Верхняя серая часть
              Container(
                width: double.infinity,
                height: 200,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Добро пожаловать',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Войдите чтобы продолжить путешествие',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Белый блок с формой
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Переключатель Логин/Регистрация
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5D7CF9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Логин',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _goToRegister,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Регистрация',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF7F8C8D),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Сообщение об ошибке
                    if (_errorMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFFFF6B6B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    if (_errorMessage.isNotEmpty) const SizedBox(height: 16),
                    
                    // Поле ввода почты
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Почта',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE8EDF2),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              hintText: 'example@mail.com',
                            ),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Поле ввода пароля
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Пароль',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE8EDF2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    hintText: 'Введите пароль',
                                  ),
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _togglePasswordVisibility,
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF7F8C8D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Кнопка входа
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D7CF9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Войти',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Ссылка на регистрацию
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Нет аккаунта? ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF7F8C8D),
                          ),
                        ),
                        TextButton(
                          onPressed: _goToRegister,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Зарегистрируйтесь',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF5D7CF9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}