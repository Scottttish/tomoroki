// lib\task_creation_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'recommendations_page.dart';
import 'chats_page.dart';
import 'profile_page.dart';
import 'services/task_service.dart';
import 'services/subtask_service.dart';
import 'models/task_model.dart';
import 'models/subtask_model.dart';

class TaskCreationPage extends StatefulWidget {
  const TaskCreationPage({super.key});

  @override
  State<TaskCreationPage> createState() => _TaskCreationPageState();
}

class _TaskCreationPageState extends State<TaskCreationPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TaskService _taskService = TaskService();
  final SubtaskService _subtaskService = SubtaskService();
  
  String _taskType = 'Собственная';
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  
  String _priority = 'medium';
  String? _selectedTeamId;
  List<String> _assignedUsers = [];
  
  final List<Subtask> _subtasks = [];
  bool _isLoading = false;

  // НАВИГАЦИОННЫЙ ИНДЕКС
  int _currentNavIndex = 2;
  
  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _addSubtask() {
    setState(() {
      _subtasks.add(Subtask(
        name: '',
        participants: [],
        startDate: null,
        startTime: null,
        endDate: null,
        endTime: null,
      ));
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  Future<void> _createTask() async {
    if (_taskNameController.text.isEmpty) {
      _showErrorSnackbar('Введите название задачи');
      return;
    }
    
    if (_startDate == null || _startTime == null || _endDate == null || _endTime == null) {
      _showErrorSnackbar('Укажите дату и время начала/окончания');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Получаем текущего пользователя
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      // Создаем DateTime объекты из даты и времени
      final startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      
      final endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      // Рассчитываем estimated duration в минутах
      final estimatedDuration = endDateTime.difference(startDateTime).inMinutes;

      // Создаем задачу
      final task = TaskModel(
        id: '', // Будет создано в базе
        title: _taskNameController.text,
        description: _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : null,
        userId: user.id,
        teamId: _taskType == 'По команде' ? _selectedTeamId : null,
        status: 'todo',
        priority: _priority,
        startTime: startDateTime,
        endTime: endDateTime,
        estimatedDuration: estimatedDuration,
        color: const Color(0xFF5D7CF9),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Сохраняем задачу в базу
      final createdTask = await _taskService.createTask(task);
      
      // Создаем подзадачи
      for (final subtask in _subtasks) {
        if (subtask.name.isNotEmpty) {
          DateTime? subtaskStartDateTime;
          DateTime? subtaskEndDateTime;
          
          if (subtask.startDate != null && subtask.startTime != null) {
            subtaskStartDateTime = DateTime(
              subtask.startDate!.year,
              subtask.startDate!.month,
              subtask.startDate!.day,
              subtask.startTime!.hour,
              subtask.startTime!.minute,
            );
          }
          
          if (subtask.endDate != null && subtask.endTime != null) {
            subtaskEndDateTime = DateTime(
              subtask.endDate!.year,
              subtask.endDate!.month,
              subtask.endDate!.day,
              subtask.endTime!.hour,
              subtask.endTime!.minute,
            );
          }

          final subtaskModel = SubtaskModel(
            id: '',
            taskId: createdTask.id,
            title: subtask.name,
            status: 'todo',
            priority: 'medium',
            orderIndex: _subtasks.indexOf(subtask),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _subtaskService.createSubtask(subtaskModel);
        }
      }

      // Показываем успешное сообщение
      _showSuccessSnackbar('Задача успешно создана!');
      
      // Ждем немного и возвращаемся
      await Future.delayed(const Duration(milliseconds: 500));
      
      Navigator.pop(context, true); // Передаем true как флаг успешного создания
      
    } catch (e) {
      print('Ошибка создания задачи: $e');
      _showErrorSnackbar('Ошибка создания задачи: ${e.toString()}');
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

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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
        // Уже на создании задачи
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatsPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  Future<void> _loadTeams() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final teams = await _supabase
            .from('team_members')
            .select('teams(*)')
            .eq('user_id', user.id)
            .eq('is_accepted', true);
        
        if (teams.isNotEmpty && _selectedTeamId == null) {
          setState(() {
            _selectedTeamId = teams[0]['teams']['id'];
          });
        }
      }
    } catch (e) {
      print('Ошибка загрузки команд: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Stack(
        children: [
          Column(
            children: [
              // Аппбар
              Container(
                color: Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF2C3E50),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Создание задачи',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Тип задачи
                      _buildSectionTitle('Тип задачи'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTaskTypeButton(
                                'Собственная',
                                _taskType == 'Собственная',
                                () {
                                  setState(() {
                                    _taskType = 'Собственная';
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: _buildTaskTypeButton(
                                'По команде',
                                _taskType == 'По команде',
                                () {
                                  setState(() {
                                    _taskType = 'По команде';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Название задачи
                      _buildSectionTitle('Название задачи'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _taskNameController,
                          decoration: InputDecoration(
                            hintText: 'Введите название задачи',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFFBDC3C7),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF2C3E50),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Описание задачи
                      _buildSectionTitle('Описание задачи (необязательно)'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Добавьте описание задачи...',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFFBDC3C7),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF2C3E50),
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Приоритет
                      _buildSectionTitle('Приоритет'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _buildPriorityButton('Высокий', 'high'),
                            _buildPriorityButton('Средний', 'medium'),
                            _buildPriorityButton('Низкий', 'low'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Дедлайн
                      _buildSectionTitle('Дедлайн'),
                      const SizedBox(height: 12),
                      
                      // Дата и время начала
                      _buildDateTimeRow(
                        'Начало',
                        _startDate != null
                            ? DateFormat('dd.MM.yyyy').format(_startDate!)
                            : 'Выбрать дату',
                        _startTime != null
                            ? _startTime!.format(context)
                            : 'Выбрать время',
                        () => _selectStartDate(context),
                        () => _selectStartTime(context),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Дата и время окончания
                      _buildDateTimeRow(
                        'Окончание',
                        _endDate != null
                            ? DateFormat('dd.MM.yyyy').format(_endDate!)
                            : 'Выбрать дату',
                        _endTime != null
                            ? _endTime!.format(context)
                            : 'Выбрать время',
                        () => _selectEndDate(context),
                        () => _selectEndTime(context),
                      ),

                      const SizedBox(height: 24),

                      // Подзадачи
                      Row(
                        children: [
                          _buildSectionTitle('Подзадачи'),
                          const Spacer(),
                          GestureDetector(
                            onTap: _addSubtask,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5D7CF9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Добавить',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      ..._subtasks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final subtask = entry.value;
                        return _buildSubtaskItem(index, subtask);
                      }).toList(),

                      const SizedBox(height: 40),

                      // Кнопки
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'Отмена',
                              const Color(0xFFF8FAFD),
                              const Color(0xFF5D7CF9),
                              () => Navigator.pop(context),
                              hasBorder: true,
                              isLoading: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionButton(
                              _isLoading ? 'Создание...' : 'Создать задачу',
                              const Color(0xFF5D7CF9),
                              Colors.white,
                              _isLoading ? null : _createTask,
                              isLoading: _isLoading,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Индикатор загрузки
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF5D7CF9),
                ),
              ),
            ),
        ],
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildTaskTypeButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5D7CF9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF2C3E50),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityButton(String text, String priority) {
    final isSelected = _priority == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _priority = priority;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? _getPriorityColor(priority) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF2C3E50),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return const Color(0xFFFF6B6B);
      case 'medium':
        return const Color(0xFF5D7CF9);
      case 'low':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF5D7CF9);
    }
  }

  Widget _buildDateTimeRow(
    String label,
    String dateText,
    String timeText,
    VoidCallback onDateTap,
    VoidCallback onTimeTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7F8C8D),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeButton(
                dateText,
                Icons.calendar_today,
                onDateTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateTimeButton(
                timeText,
                Icons.access_time,
                onTimeTap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeButton(
    String text,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF5D7CF9),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: text.contains('Выбрать')
                      ? const Color(0xFFBDC3C7)
                      : const Color(0xFF2C3E50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtaskItem(int index, Subtask subtask) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Text(
                'Подзадача ${index + 1}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _removeSubtask(index),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.delete,
                      color: Color(0xFFFF6B6B),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Название подзадачи
          TextField(
            onChanged: (value) {
              setState(() {
                _subtasks[index].name = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Название подзадачи',
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFFBDC3C7),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFD),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: GoogleFonts.inter(
              color: const Color(0xFF2C3E50),
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Время подзадачи
          Row(
            children: [
              Expanded(
                child: _buildSubtaskDateTime(
                  'Начало',
                  subtask.startDate != null
                      ? DateFormat('dd.MM.yyyy').format(subtask.startDate!)
                      : 'Дата',
                  subtask.startTime != null
                      ? subtask.startTime!.format(context)
                      : 'Время',
                  () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _subtasks[index].startDate = picked;
                      });
                    }
                  },
                  () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _subtasks[index].startTime = picked;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSubtaskDateTime(
                  'Окончание',
                  subtask.endDate != null
                      ? DateFormat('dd.MM.yyyy').format(subtask.endDate!)
                      : 'Дата',
                  subtask.endTime != null
                      ? subtask.endTime!.format(context)
                      : 'Время',
                  () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _subtasks[index].endDate = picked;
                      });
                    }
                  },
                  () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _subtasks[index].endTime = picked;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskDateTime(
    String label,
    String dateText,
    String timeText,
    VoidCallback onDateTap,
    VoidCallback onTimeTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7F8C8D),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onDateTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                dateText,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: dateText == 'Дата'
                      ? const Color(0xFFBDC3C7)
                      : const Color(0xFF2C3E50),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTimeTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                timeText,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: timeText == 'Время'
                      ? const Color(0xFFBDC3C7)
                      : const Color(0xFF2C3E50),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String text,
    Color backgroundColor,
    Color textColor,
    VoidCallback? onPressed, {
    bool hasBorder = false,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: hasBorder
              ? const BorderSide(color: Color(0xFF5D7CF9), width: 2)
              : BorderSide.none,
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

class Subtask {
  String name;
  List<String> participants;
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;

  Subtask({
    required this.name,
    required this.participants,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
  });
}