// lib/profile_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'recommendations_page.dart';
import 'chats_page.dart';
import 'task_creation_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Данные пользователя
  String _username = '@aslan_dev';
  String _email = 'aslan@example.com';
  String _fullName = 'Aslan Developer';
  bool _isEditingUsername = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  
  // Загрузка
  bool _isLoading = true;
  bool _isUpdating = false;
  
  // НАВИГАЦИОННЫЙ ИНДЕКС
  int _currentNavIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        setState(() {
          _email = user.email ?? 'email@example.com';
          _username = '@${user.email?.split('@').first ?? 'user'}';
          _fullName = user.userMetadata?['full_name']?.toString() ?? 
                     user.email?.split('@').first ?? 'Пользователь';
        });

        // Пробуем получить данные из таблицы users
        try {
          final userData = await _supabase
              .from('users')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          if (userData != null) {
            setState(() {
              _username = '@${userData['username'] ?? user.email?.split('@').first ?? 'user'}';
              _fullName = userData['full_name']?.toString() ?? _fullName;
            });
          }
        } catch (e) {
          print('Ошибка загрузки данных пользователя: $e');
        }
      }
    } catch (e) {
      print('Ошибка загрузки пользователя: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUsername() async {
    if (_usernameController.text.isEmpty) return;
    
    setState(() {
      _isUpdating = true;
    });
    
    try {
      final newUsername = _usernameController.text.trim();
      final user = _supabase.auth.currentUser;
      
      if (user != null) {
        // Обновляем в таблице users
        await _supabase
            .from('users')
            .update({
              'username': newUsername,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', user.id);
        
        // Обновляем в метаданных auth
        await _supabase.auth.updateUser(
          UserAttributes(
            data: {
              'username': newUsername,
              'full_name': newUsername,
            },
          ),
        );
        
        setState(() {
          _username = '@$newUsername';
          _fullName = newUsername;
          _isEditingUsername = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Никнейм успешно обновлен'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Ошибка обновления никнейма: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление аккаунта'),
        content: const Text(
          'Вы уверены, что хотите удалить свой аккаунт? '
          'Все ваши данные будут безвозвратно удалены. '
          'Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDeleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Удалить аккаунт'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user != null) {
        // 1. Удаляем из таблицы users
        try {
          await _supabase
              .from('users')
              .delete()
              .eq('id', user.id);
        } catch (e) {
          print('Ошибка удаления из таблицы: $e');
        }
        
        // 2. Удаляем пользователя из auth
        await _supabase.auth.signOut();
        
        // 3. Перенаправляем на страницу входа
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Аккаунт успешно удален'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Ошибка удаления аккаунта: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка удаления: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ОБНОВЛЕННАЯ НАВИГАЦИЯ С ПЕРЕХОДАМИ
  void _onNavItemTapped(int index) {
    if (_currentNavIndex == index) return;
    
    setState(() {
      _currentNavIndex = index;
    });
    
    // НЕМЕДЛЕННЫЙ ПЕРЕХОД ПО НАЖАТИЮ
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FlowTimeHomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RecommendationsPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TaskCreationPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatsPage()),
        );
        break;
      case 4:
        // Уже на профиле
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 20),
                    
                    _buildAccountSettings(),
                    const SizedBox(height: 20),
                    
                    _buildUserInfo(),
                    const SizedBox(height: 20),
                    
                    _buildDangerZone(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      
      // НАВИГАЦИОННАЯ ПАНЕЛЬ
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5D7CF9),
        unselectedItemColor: const Color(0xFF7F8C8D),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'Советы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Создать',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outlined),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Чаты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5D7CF9), Color(0xFF7B6CF2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5D7CF9).withAlpha(76),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _username.substring(1, 3).toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _fullName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5D7CF9),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EDF2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Flutter Developer',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF7F8C8D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EBFF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Pro Member',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5D7CF9),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Настройки аккаунта',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Редактирование никнейма
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Никнейм',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isEditingUsername = !_isEditingUsername;
                        if (_isEditingUsername) {
                          _usernameController.text = _username.substring(1);
                          _fullNameController.text = _fullName;
                        }
                      });
                    },
                    icon: Icon(
                      _isEditingUsername ? Icons.close : Icons.edit,
                      size: 20,
                      color: const Color(0xFF5D7CF9),
                    ),
                  ),
                ],
              ),
              
              if (_isEditingUsername) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Новый никнейм',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixText: '@',
                    hintText: 'username',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Полное имя',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Имя Фамилия',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : _updateUsername,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D7CF9),
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Сохранить изменения'),
                  ),
                ),
                const SizedBox(height: 8),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  _username,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5D7CF9),
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _email,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Дата регистрации
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Дата регистрации',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Сегодня',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Информация о пользователе',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Статистика (упрощенная)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('0', 'Задач создано'),
              _buildStatItem('0', 'Задач выполнено'),
              _buildStatItem('0 ч', 'Потрачено времени'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Роль
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Роль в системе',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EBFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Пользователь',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5D7CF9),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Статус аккаунта
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Статус аккаунта',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Активен',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Опасная зона',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Действия в этом разделе нельзя отменить. '
            'Будьте внимательны при их выполнении.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Выход из аккаунта
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8EDF2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выйти из аккаунта',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Завершите текущую сессию на этом устройстве',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await _supabase.auth.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF5D7CF9)),
                    ),
                    child: const Text('Выйти'),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Удаление аккаунта
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE0E0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Удалить аккаунт',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Все ваши данные будут удалены безвозвратно. '
                  'Это действие нельзя отменить.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Удалить аккаунт'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}