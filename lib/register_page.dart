// lib/register_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  PasswordStrength _passwordStrength = PasswordStrength.weak;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      
      final score = [
        _hasMinLength,
        _hasUppercase,
        _hasLowercase,
        _hasNumber,
        _hasSpecialChar,
      ].where((item) => item).length;
      
      if (score < 2) {
        _passwordStrength = PasswordStrength.weak;
      } else if (score < 4) {
        _passwordStrength = PasswordStrength.medium;
      } else {
        _passwordStrength = PasswordStrength.strong;
      }
    });
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackbar('Пароли не совпадают');
      return;
    }
    
    if (_passwordStrength != PasswordStrength.strong) {
      _showErrorSnackbar('Пароль недостаточно надежный');
      return;
    }
    
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (nickname.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorSnackbar('Заполните все поля');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        username: nickname,
        fullName: nickname,
        telegramUsername: null,
      );
      
      if (user != null) {
        // УСПЕШНАЯ РЕГИСТРАЦИЯ - сразу переходим на главную
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FlowTimeHomePage()),
        );
      } else {
        setState(() {
          _errorMessage = 'Ошибка регистрации';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
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
                        'Давайте приступим',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Создайте аккаунт чтобы начать работу',
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
                              onTap: _goToLogin,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Логин',
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
                                    'Регистрация',
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
                    
                    // Поле ввода никнейма
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Никнейм',
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
                            controller: _nicknameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              hintText: 'Введите ваш никнейм',
                            ),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
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
                                  onChanged: _checkPasswordStrength,
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
                    
                    const SizedBox(height: 16),
                    
                    // Индикатор сложности пароля
                    _buildPasswordStrengthIndicator(),
                    
                    const SizedBox(height: 20),
                    
                    // Поле повторения пароля
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Повторите пароль',
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
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    hintText: 'Повторите пароль',
                                  ),
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _toggleConfirmPasswordVisibility,
                                icon: Icon(
                                  _obscureConfirmPassword
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
                    
                    // Кнопка регистрации
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
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
                                'Зарегистрироваться',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Ссылка на вход
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Уже есть аккаунт? ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF7F8C8D),
                          ),
                        ),
                        TextButton(
                          onPressed: _goToLogin,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Войти',
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

  Widget _buildPasswordStrengthIndicator() {
    Color getStrengthColor() {
      switch (_passwordStrength) {
        case PasswordStrength.weak:
          return const Color(0xFFFF6B6B);
        case PasswordStrength.medium:
          return const Color(0xFFFFC107);
        case PasswordStrength.strong:
          return const Color(0xFF4CAF50);
      }
    }
    
    String getStrengthText() {
      switch (_passwordStrength) {
        case PasswordStrength.weak:
          return 'Слабый пароль';
        case PasswordStrength.medium:
          return 'Средний пароль';
        case PasswordStrength.strong:
          return 'Надежный пароль';
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Прогресс бар
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EDF2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _passwordStrength == PasswordStrength.weak 
                ? 0.33 
                : _passwordStrength == PasswordStrength.medium
                  ? 0.66
                  : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: getStrengthColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Текст силы пароля
        Text(
          getStrengthText(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: getStrengthColor(),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Требования к паролю
        Column(
          children: [
            _buildRequirementItem('Минимум 8 символов', _hasMinLength),
            const SizedBox(height: 6),
            _buildRequirementItem('Заглавная буква (A-Z)', _hasUppercase),
            const SizedBox(height: 6),
            _buildRequirementItem('Строчная буква (a-z)', _hasLowercase),
            const SizedBox(height: 6),
            _buildRequirementItem('Цифра (0-9)', _hasNumber),
            const SizedBox(height: 6),
            _buildRequirementItem('Специальный символ', _hasSpecialChar),
          ],
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle,
          size: 16,
          color: isMet ? const Color(0xFF4CAF50) : const Color(0xFFBDC3C7),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isMet ? const Color(0xFF4CAF50) : const Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }
}

enum PasswordStrength {
  weak,
  medium,
  strong,
}