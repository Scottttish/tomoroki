// lib/home_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'chats_page.dart';
import 'profile_page.dart';
import 'recommendations_page.dart';
import 'task_creation_page.dart';

// Классы для FlowTimeHomePage
class AppUsageSegment {
  final String name;
  final Color color;
  final Color lightColor;
  final double percentage;
  final List<AppUsage> apps;

  AppUsageSegment({
    required this.name,
    required this.color,
    required this.lightColor,
    required this.percentage,
    required this.apps,
  });
}

class AppUsage {
  final String name;
  final int launchCount;
  final List<String> timeIntervals;
  final double usagePercentage;
  bool isIgnored;

  AppUsage({
    required this.name,
    required this.launchCount,
    required this.timeIntervals,
    required this.usagePercentage,
    this.isIgnored = false,
  });
}

class TeamMember {
  final String name;
  final String role;
  final String access;
  final String timeInTeam;
  final String avatar;
  final String gender;
  final List<String> teams;
  final List<Task> assignedTasks;

  TeamMember({
    required this.name,
    required this.role,
    required this.access,
    required this.timeInTeam,
    required this.avatar,
    required this.gender,
    required this.teams,
    required this.assignedTasks,
  });
}

class Team {
  final String name;
  final List<TeamMember> members;
  final Color color;

  Team({
    required this.name,
    required this.members,
    required this.color,
  });
}

class Task {
  final String id;
  final String name;
  final String type;
  final DateTime startDate;
  DateTime endDate;
  final List<Subtask> subtasks;
  final List<String> participants;
  final Color color;
  final double startHour;
  final double endHour;
  bool isCompleted;
  bool isCancelled;

  Task({
    required this.id,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.subtasks,
    required this.participants,
    required this.color,
    required this.startHour,
    required this.endHour,
    this.isCompleted = false,
    this.isCancelled = false,
  });
}

class Subtask {
  final String id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> participants;
  bool isCompleted;

  Subtask({
    required this.id,
    required this.name,
    this.startDate,
    this.endDate,
    required this.participants,
    this.isCompleted = false,
  });
}

class SearchResult {
  final String name;
  final IconData icon;
  final String? taskId;
  final String? subtaskId;

  SearchResult({
    required this.name,
    required this.icon,
    this.taskId,
    this.subtaskId,
  });
}

class FlowTimeHomePage extends StatefulWidget {
  final DateTime? selectedDate;

  const FlowTimeHomePage({super.key, this.selectedDate});

  @override
  State<FlowTimeHomePage> createState() => _FlowTimeHomePageState();
}

class _FlowTimeHomePageState extends State<FlowTimeHomePage> {
  int _currentTaskIndex = 0;
  int? _selectedCategoryIndex;
  int? _selectedTeamIndex;
  bool _showTeamDetails = false;
  final ScrollController _teamsScrollController = ScrollController();
  final Map<int, bool> _memberMenuHover = {};
  
  int _currentNavIndex = 0;
  late DateTime _currentDate;
  
  late Timer _timer;
  Duration _remainingTime = Duration.zero;
  
  bool _showSearchModal = false;
  bool _showCalendarModal = false;
  bool _showCreateTeamModal = false;
  bool _showAppSettingsModal = false;
  bool _showTaskDetailsModal = false;
  bool _showMemberDetailsModal = false;
  bool _showSubtaskSearchModal = false;
  
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _telegramUsernameController = TextEditingController();
  
  bool _isLocaleInitialized = false;
  late Future<void> _initLocaleFuture;
  
  Task? _selectedTask;
  Subtask? _selectedSubtask;
  int? _selectedTaskIndexForProgressBar;
  
  final List<int> _extensionMinutes = [5, 10, 15, 30, 45, 60];
  int _selectedExtension = 15;
  
  final List<SearchResult> _taskSearchResults = [];
  final List<SearchResult> _subtaskSearchResults = [];
  final List<SearchResult> _peopleSearchResults = [];

  final List<Task> _tasks = [
    Task(
      id: '1',
      name: 'Работа над проектом',
      type: 'Собственная',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(hours: 2)),
      subtasks: [
        Subtask(
          id: '1_1',
          name: 'Разработка интерфейса',
          participants: ['Алихан', 'Сания'],
        ),
        Subtask(
          id: '1_2',
          name: 'Тестирование API',
          participants: ['Амир'],
        ),
      ],
      participants: ['Алихан', 'Сания', 'Амир'],
      color: const Color(0xFF5D7CF9),
      startHour: 9.0,
      endHour: 11.0,
    ),
    Task(
      id: '2',
      name: 'Совещание',
      type: 'По команде',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(hours: 1)),
      subtasks: [
        Subtask(
          id: '2_1',
          name: 'Обсуждение дизайна',
          participants: ['Сания'],
        ),
      ],
      participants: ['Все'],
      color: const Color(0xFF4AC0C2),
      startHour: 11.5,
      endHour: 12.5,
    ),
    Task(
      id: '3',
      name: 'Обед',
      type: 'Собственная',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(hours: 1)),
      subtasks: [],
      participants: [],
      color: const Color(0xFFFF9A6A),
      startHour: 13.0,
      endHour: 14.0,
    ),
    Task(
      id: '4',
      name: 'Изучение нового',
      type: 'Собственная',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(hours: 2)),
      subtasks: [
        Subtask(
          id: '4_1',
          name: 'Изучение Flutter',
          participants: ['Алихан'],
        ),
        Subtask(
          id: '4_2',
          name: 'Практика',
          participants: ['Алихан'],
        ),
      ],
      participants: ['Алихан'],
      color: const Color(0xFF7B6CF2),
      startHour: 15.0,
      endHour: 17.0,
    ),
  ];

  final List<AppUsageSegment> _usageSegments = [
    AppUsageSegment(
      name: 'Игры',
      color: const Color(0xFF7B6CF2),
      lightColor: const Color(0xFFE8E6FD),
      percentage: 22.0,
      apps: [
        AppUsage(name: 'PUBG Mobile', launchCount: 7, timeIntervals: ['16:04-17:23', '19:30-20:45'], usagePercentage: 45),
        AppUsage(name: 'FreeFire', launchCount: 5, timeIntervals: ['10:54-13:21'], usagePercentage: 35),
        AppUsage(name: 'Among Us', launchCount: 3, timeIntervals: ['14:15-15:30'], usagePercentage: 15),
        AppUsage(name: 'Mobile Legends', launchCount: 2, timeIntervals: ['21:00-21:45'], usagePercentage: 5),
      ],
    ),
    AppUsageSegment(
      name: 'Соцсети',
      color: const Color(0xFF4AC0C2),
      lightColor: const Color(0xFFE0F7F7),
      percentage: 13.0,
      apps: [
        AppUsage(name: 'Instagram', launchCount: 15, timeIntervals: ['09:15-10:30', '14:00-15:45'], usagePercentage: 40),
        AppUsage(name: 'Telegram', launchCount: 12, timeIntervals: ['08:00-09:00', '18:20-19:10'], usagePercentage: 35),
        AppUsage(name: 'WhatsApp', launchCount: 8, timeIntervals: ['12:30-13:15'], usagePercentage: 15),
        AppUsage(name: 'Facebook', launchCount: 5, timeIntervals: ['20:00-20:45'], usagePercentage: 10),
      ],
    ),
    AppUsageSegment(
      name: 'Работа',
      color: const Color(0xFF5D7CF9),
      lightColor: const Color(0xFFE6EBFF),
      percentage: 25.0,
      apps: [
        AppUsage(name: 'VS Code', launchCount: 12, timeIntervals: ['08:30-12:00', '13:15-17:45'], usagePercentage: 50),
        AppUsage(name: 'Figma', launchCount: 8, timeIntervals: ['10:00-11:30'], usagePercentage: 25),
        AppUsage(name: 'Jira', launchCount: 5, timeIntervals: ['09:00-09:30'], usagePercentage: 15),
        AppUsage(name: 'Slack', launchCount: 3, timeIntervals: ['08:15-08:45'], usagePercentage: 10),
      ],
    ),
    AppUsageSegment(
      name: 'Музыка',
      color: const Color(0xFFFF9A6A),
      lightColor: const Color(0xFFFFF0E8),
      percentage: 20.0,
      apps: [
        AppUsage(name: 'Spotify', launchCount: 5, timeIntervals: ['07:45-08:30', '17:50-18:40'], usagePercentage: 60),
        AppUsage(name: 'YouTube Music', launchCount: 3, timeIntervals: ['19:00-19:45'], usagePercentage: 30),
        AppUsage(name: 'Apple Music', launchCount: 2, timeIntervals: ['20:30-21:00'], usagePercentage: 10),
      ],
    ),
    AppUsageSegment(
      name: 'Прочее',
      color: const Color(0xFF9E9E9E),
      lightColor: const Color(0xFFF5F5F5),
      percentage: 20.0,
      apps: [
        AppUsage(name: 'Настройки', launchCount: 8, timeIntervals: ['06:30-07:15', '12:45-13:10'], usagePercentage: 40),
        AppUsage(name: 'Галерея', launchCount: 6, timeIntervals: ['20:00-20:30'], usagePercentage: 30),
        AppUsage(name: 'Камера', launchCount: 4, timeIntervals: ['11:00-11:15'], usagePercentage: 20),
        AppUsage(name: 'Браузер', launchCount: 3, timeIntervals: ['15:30-15:50'], usagePercentage: 10),
      ],
    ),
  ];

  final List<Team> _teams = [
    Team(
      name: 'AITU',
      members: [
        TeamMember(
          name: 'Алихан',
          role: 'Frontend Dev',
          access: 'Админ',
          timeInTeam: '45 дней',
          avatar: '👨‍💻',
          gender: 'male',
          teams: ['AITU', 'TechLab'],
          assignedTasks: [],
        ),
        TeamMember(
          name: 'Сания',
          role: 'UI/UX Дизайнер',
          access: 'Редактор',
          timeInTeam: '30 дней',
          avatar: '👩‍🎨',
          gender: 'female',
          teams: ['AITU'],
          assignedTasks: [],
        ),
        TeamMember(
          name: 'Амир',
          role: 'Backend Dev',
          access: 'Редактор',
          timeInTeam: '60 дней',
          avatar: '👨‍💻',
          gender: 'male',
          teams: ['AITU'],
          assignedTasks: [],
        ),
      ],
      color: const Color(0xFF5D7CF9),
    ),
    Team(
      name: 'Astana Bridge',
      members: [
        TeamMember(
          name: 'Данияр',
          role: 'Аналитик',
          access: 'Админ',
          timeInTeam: '90 дней',
          avatar: '👨‍💼',
          gender: 'male',
          teams: ['Astana Bridge'],
          assignedTasks: [],
        ),
        TeamMember(
          name: 'Айгерим',
          role: 'Бухгалтер',
          access: 'Просмотр',
          timeInTeam: '120 дней',
          avatar: '👩‍💼',
          gender: 'female',
          teams: ['Astana Bridge'],
          assignedTasks: [],
        ),
      ],
      color: const Color(0xFF4AC0C2),
    ),
  ];

  _FlowTimeHomePageState() : _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.selectedDate != null) {
      _currentDate = widget.selectedDate!;
    }
    
    _initLocaleFuture = _initializeLocale();
    _updateSearchResults();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
    
    _updateRemainingTime();
  }

  void _updateRemainingTime() {
    if (_tasks.isEmpty || _currentTaskIndex >= _tasks.length) return;
    
    final task = _tasks[_currentTaskIndex];
    if (task.isCompleted || task.isCancelled) {
      _remainingTime = Duration.zero;
    } else {
      final now = DateTime.now();
      _remainingTime = task.endDate.isAfter(now) 
          ? task.endDate.difference(now)
          : Duration.zero;
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeLocale() async {
    if (!_isLocaleInitialized) {
      await initializeDateFormatting('ru');
      _isLocaleInitialized = true;
    }
  }

  void _updateSearchResults() {
    _taskSearchResults.clear();
    _subtaskSearchResults.clear();
    _peopleSearchResults.clear();
    
    for (var task in _tasks) {
      _taskSearchResults.add(SearchResult(
        name: task.name,
        icon: Icons.task,
        taskId: task.id,
      ));
      
      for (var subtask in task.subtasks) {
        _subtaskSearchResults.add(SearchResult(
          name: subtask.name,
          icon: Icons.subdirectory_arrow_right,
          taskId: task.id,
          subtaskId: subtask.id,
        ));
      }
    }
    
    for (var team in _teams) {
      for (var member in team.members) {
        if (!_peopleSearchResults.any((p) => p.name == member.name)) {
          _peopleSearchResults.add(SearchResult(
            name: member.name,
            icon: Icons.person,
          ));
        }
      }
    }
  }

  void _onNavItemTapped(int index) {
    if (_currentNavIndex == index) return;
    
    setState(() {
      _currentNavIndex = index;
    });
    
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RecommendationsPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TaskCreationPage()),
        ).then((value) {
          if (value != null && value is Task) {
            setState(() {
              _tasks.add(value);
              _updateSearchResults();
              _updateRemainingTime();
            });
          }
        });
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatsPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _currentNavIndex = 0;
        });
      }
    });
  }

  void _toggleCategorySelection(int index) {
    setState(() {
      if (_selectedCategoryIndex == index) {
        _selectedCategoryIndex = null;
      } else {
        _selectedCategoryIndex = index;
      }
    });
  }

  void _toggleTeamSelection(int index) {
    setState(() {
      if (_selectedTeamIndex == index) {
        _selectedTeamIndex = null;
        _showTeamDetails = false;
      } else {
        _selectedTeamIndex = index;
        _showTeamDetails = true;
      }
    });
  }

  void _onMemberMenuHover(int index, bool hovering) {
    setState(() {
      _memberMenuHover[index] = hovering;
    });
  }

  void _showSearchModalFunc() {
    setState(() {
      _showSearchModal = true;
    });
  }

  void _hideSearchModal() {
    setState(() {
      _showSearchModal = false;
      _searchController.clear();
    });
  }

  void _showCalendarModalFunc() {
    setState(() {
      _showCalendarModal = true;
    });
  }

  void _hideCalendarModal() {
    setState(() {
      _showCalendarModal = false;
    });
  }

  void _showCreateTeamModalFunc() {
    setState(() {
      _showCreateTeamModal = true;
    });
  }

  void _hideCreateTeamModal() {
    setState(() {
      _showCreateTeamModal = false;
      _teamNameController.clear();
      _telegramUsernameController.clear();
    });
  }

  void _showAppSettingsModalFunc() {
    setState(() {
      _showAppSettingsModal = true;
    });
  }

  void _hideAppSettingsModal() {
    setState(() {
      _showAppSettingsModal = false;
    });
  }

  void _showTaskDetailsModalFunc(Task task, {Subtask? subtask}) {
    setState(() {
      _selectedTask = task;
      _selectedSubtask = subtask;
      _showTaskDetailsModal = true;
    });
  }

  void _hideTaskDetailsModal() {
    setState(() {
      _showTaskDetailsModal = false;
      _selectedTask = null;
      _selectedSubtask = null;
    });
  }

  void _showMemberDetailsModalFunc(TeamMember member) {
    setState(() {
      _showMemberDetailsModal = true;
    });
  }

  void _hideMemberDetailsModal() {
    setState(() {
      _showMemberDetailsModal = false;
    });
  }

  void _showSubtaskSearchModalFunc(Task task, Subtask subtask) {
    setState(() {
      _selectedTask = task;
      _selectedSubtask = subtask;
      _showSubtaskSearchModal = true;
    });
  }

  void _hideSubtaskSearchModal() {
    setState(() {
      _showSubtaskSearchModal = false;
      _selectedTask = null;
      _selectedSubtask = null;
    });
  }

  void _onProgressBarTaskTap(int index) {
    setState(() {
      _selectedTaskIndexForProgressBar = index;
    });
    if (index < _tasks.length) {
      final task = _tasks[index];
      final subtask = task.subtasks.isNotEmpty ? task.subtasks[0] : null;
      _showTaskDetailsModalFunc(task, subtask: subtask);
    }
  }

  void _completeTask(Task task) {
    setState(() {
      task.isCompleted = true;
      for (var subtask in task.subtasks) {
        subtask.isCompleted = true;
      }
    });
    _hideTaskDetailsModal();
    _updateRemainingTime();
  }

  void _cancelTask(Task task) {
    setState(() {
      task.isCancelled = true;
    });
    _hideTaskDetailsModal();
    _updateRemainingTime();
  }

  void _extendTask(Task task, int minutes) {
    setState(() {
      task.endDate = task.endDate.add(Duration(minutes: minutes));
    });
    _hideTaskDetailsModal();
    _updateRemainingTime();
  }

  void _completeSubtask(Task task, Subtask subtask) {
    setState(() {
      subtask.isCompleted = true;
      if (task.subtasks.every((s) => s.isCompleted)) {
        task.isCompleted = true;
      }
    });
    _updateRemainingTime();
  }

  void _toggleAppIgnore(AppUsage app) {
    setState(() {
      app.isIgnored = !app.isIgnored;
    });
  }

  void _inviteToTelegram(String username) {
    if (kDebugMode) {
      print('Отправка приглашения через Telegram бота пользователю: @$username');
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Приглашение отправлено'),
        content: Text('Приглашение отправлено пользователю @$username через Telegram бота. '
            'Ожидайте подтверждения.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addToFriends(TeamMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавлено в друзья'),
        content: Text('${member.name} добавлен(а) в ваши друзья.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onSearchResultTap(SearchResult result) {
    if (result.taskId != null) {
      final task = _tasks.firstWhere((t) => t.id == result.taskId);
      if (result.subtaskId != null) {
        final subtask = task.subtasks.firstWhere((s) => s.id == result.subtaskId);
        _showTaskDetailsModalFunc(task, subtask: subtask);
      } else {
        _showTaskDetailsModalFunc(task);
      }
      _hideSearchModal();
    }
  }

  void _onSubtaskTap(Task task, Subtask subtask) {
    _showSubtaskSearchModalFunc(task, subtask);
  }

  @override
  void dispose() {
    _teamsScrollController.dispose();
    _searchController.dispose();
    _teamNameController.dispose();
    _telegramUsernameController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initLocaleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFD),
            body: Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF5D7CF9),
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFD),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildMainContent();
      },
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildDateHeader(),
                      const SizedBox(height: 15),
                      _buildSemicircleClock(),
                      const SizedBox(height: 15),
                      _buildAppUsageBlock(),
                      const SizedBox(height: 15),
                      _buildTeamsBlock(),
                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          if (_showSearchModal) _buildSearchModal(),
          if (_showCalendarModal) _buildCalendarModal(),
          if (_showCreateTeamModal) _buildCreateTeamModal(),
          if (_showAppSettingsModal) _buildAppSettingsModal(),
          if (_showTaskDetailsModal && _selectedTask != null) _buildTaskDetailsModal(),
          if (_showMemberDetailsModal) _buildMemberDetailsModal(),
          if (_showSubtaskSearchModal && _selectedTask != null && _selectedSubtask != null) 
            _buildSubtaskSearchModal(),
        ],
      ),
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

  Widget _buildDateHeader() {
    final weekday = DateFormat('E', 'ru').format(_currentDate);
    final capitalizedWeekday = weekday[0].toUpperCase() + weekday.substring(1);
    final month = DateFormat('MMMM', 'ru').format(_currentDate);
    final capitalizedMonth = month[0].toUpperCase() + month.substring(1);
    final day = _currentDate.day;
    final formattedDay = day.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$capitalizedWeekday.',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C3E50),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        capitalizedMonth,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF7F8C8D),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Container(
            margin: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedDay,
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2C3E50),
                    height: 0.9,
                  ),
                ),
                const SizedBox(height: 12),
                
                Transform.translate(
                  offset: const Offset(0, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _showSearchModalFunc,
                          icon: Icon(
                            Icons.search,
                            color: const Color(0xFF5D7CF9),
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _showCalendarModalFunc,
                          icon: Icon(
                            Icons.calendar_today,
                            color: const Color(0xFF5D7CF9),
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemicircleClock() {
    final currentTask = _tasks[_currentTaskIndex];
    final currentSubtask = currentTask.subtasks.isNotEmpty 
        ? currentTask.subtasks[0] 
        : null;

    return SizedBox(
      height: 200, // Уменьшена высота
      child: Stack(
        children: [
          Positioned.fill(
            top: 10, // Смещен вниз
            child: GestureDetector(
              onTapDown: (TapDownDetails details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final center = Offset(MediaQuery.of(context).size.width / 2, 70); // Центр смещен
                final radius = MediaQuery.of(context).size.width * 0.35; // Уменьшен радиус
                
                final dx = localPosition.dx - center.dx;
                final dy = localPosition.dy - center.dy;
                final distance = sqrt(dx * dx + dy * dy);
                
                if (distance <= radius) {
                  double angle = atan2(dy, dx);
                  if (angle < 0) angle += 2 * pi;
                  
                  if (angle >= 0 && angle <= pi) { // Верхний полукруг
                    double hour = (angle * 24 / pi);
                    
                    for (int i = 0; i < _tasks.length; i++) {
                      final task = _tasks[i];
                      if (hour >= task.startHour && hour <= task.endHour) {
                        _onProgressBarTaskTap(i);
                        break;
                      }
                    }
                  }
                }
              },
              child: CustomPaint(
                painter: _SemicircleClockPainter(
                  tasks: _tasks,
                  currentTaskIndex: _currentTaskIndex,
                  selectedTaskIndex: _selectedTaskIndexForProgressBar,
                  onTaskTap: _onProgressBarTaskTap,
                ),
              ),
            ),
          ),
          
          Positioned(
            left: 0,
            right: 0,
            bottom: 10, // Смещен вверх
            child: Column(
              children: [
                Text(
                  currentSubtask?.name ?? currentTask.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -5),
                      child: IconButton(
                        onPressed: _currentTaskIndex > 0 
                            ? () => setState(() => _currentTaskIndex--)
                            : null,
                        icon: Icon(
                          Icons.keyboard_double_arrow_left_rounded,
                          color: _currentTaskIndex > 0
                              ? const Color(0xFF5D7CF9)
                              : const Color(0xFFCCD1DC),
                          size: 28,
                        ),
                      ),
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${currentTask.startHour.toInt().toString().padLeft(2, '0')}',
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C3E50),
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              ':',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            Text(
                              '00',
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C3E50),
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatRemainingTime(_remainingTime),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getRemainingTimeColor(_remainingTime),
                          ),
                        ),
                      ],
                    ),
                    
                    Transform.translate(
                      offset: const Offset(0, -5),
                      child: IconButton(
                        onPressed: _currentTaskIndex < _tasks.length - 1
                            ? () => setState(() => _currentTaskIndex++)
                            : null,
                        icon: Icon(
                          Icons.keyboard_double_arrow_right_rounded,
                          color: _currentTaskIndex < _tasks.length - 1
                              ? const Color(0xFF5D7CF9)
                              : const Color(0xFFCCD1DC),
                          size: 28,
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

  String _formatRemainingTime(Duration duration) {
    if (duration.inSeconds <= 0) return '00:00:00';
    final hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Color _getRemainingTimeColor(Duration duration) {
    if (duration.inMinutes < 5) {
      return const Color(0xFFFF6B6B);
    } else if (duration.inMinutes < 30) {
      return const Color(0xFFFFC107);
    }
    return const Color(0xFF7F8C8D);
  }

  Widget _buildAppUsageBlock() {
    final List<double> calculatedPercentages = [];
    for (var segment in _usageSegments) {
      final nonIgnoredApps = segment.apps.where((app) => !app.isIgnored).toList();
      if (nonIgnoredApps.isEmpty) {
        calculatedPercentages.add(0);
      } else {
        final totalUsage = nonIgnoredApps.fold(0.0, (sum, app) => sum + app.usagePercentage);
        calculatedPercentages.add(segment.percentage * (totalUsage / 100));
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Статистика приложений',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              IconButton(
                onPressed: _showAppSettingsModalFunc,
                icon: const Icon(Icons.settings, color: Color(0xFF5D7CF9)),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            height: 24,
            child: Row(
              children: _usageSegments.asMap().entries.map((entry) {
                final index = entry.key;
                final segment = entry.value;
                final percentage = calculatedPercentages[index];
                return Expanded(
                  flex: percentage > 0 ? percentage.round() : 1,
                  child: GestureDetector(
                    onTap: () => _toggleCategorySelection(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: segment.color,
                        borderRadius: _getSegmentBorderRadius(index),
                      ),
                      child: Center(
                        child: percentage > 0 ? Text(
                          '${percentage.round()}%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ) : const SizedBox(),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 12),
          
          SizedBox(
            height: 20,
            child: Row(
              children: _usageSegments.asMap().entries.map((entry) {
                final index = entry.key;
                final segment = entry.value;
                final percentage = calculatedPercentages[index];
                
                return Expanded(
                  flex: percentage > 0 ? percentage.round() : 1,
                  child: GestureDetector(
                    onTap: () => _toggleCategorySelection(index),
                    child: Container(
                      alignment: Alignment.center,
                      child: percentage > 0 ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: segment.color,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              segment.name,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2C3E50),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ) : const SizedBox(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          if (_selectedCategoryIndex != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _buildAppListTooltip(_usageSegments[_selectedCategoryIndex!]),
            ),
        ],
      ),
    );
  }

  Widget _buildAppListTooltip(AppUsageSegment segment) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: segment.lightColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: segment.color.withAlpha(51),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: segment.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    segment.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: segment.color,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Column(
                children: segment.apps.where((app) => !app.isIgnored).map((app) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                app.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Text(
                              '${app.launchCount} запусков',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EDF2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: app.usagePercentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: segment.color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: app.timeIntervals.map((interval) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: segment.color.withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                interval,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: segment.color,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsBlock() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
              Text(
                'Мои команды',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const Spacer(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            height: 120,
            child: ListView.separated(
              controller: _teamsScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _teams.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == _teams.length) {
                  return GestureDetector(
                    onTap: _showCreateTeamModalFunc,
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE8EDF2),
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF5D7CF9),
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Добавить',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5D7CF9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                final team = _teams[index];
                return GestureDetector(
                  onTap: () => _toggleTeamSelection(index),
                  child: Container(
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedTeamIndex == index ? team.color : const Color(0xFFE8EDF2),
                        width: _selectedTeamIndex == index ? 2 : 1,
                      ),
                      boxShadow: _selectedTeamIndex == index
                          ? [
                              BoxShadow(
                                color: team.color.withAlpha(25),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withAlpha(13),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          team.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: team.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.people_alt_outlined,
                              size: 14,
                              color: Color(0xFF7F8C8D),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${team.members.length} участников',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          if (_showTeamDetails && _selectedTeamIndex != null) ...[
            const SizedBox(height: 16),
            _buildTeamMembersTooltip(_teams[_selectedTeamIndex!]),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamMembersTooltip(Team team) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8EDF2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Участники',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: team.color,
            ),
          ),
          const SizedBox(height: 12),
          
          Column(
            children: team.members.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MouseRegion(
                  onEnter: (_) => _onMemberMenuHover(index, true),
                  onExit: (_) => _onMemberMenuHover(index, false),
                  child: GestureDetector(
                    onTap: () => _showMemberDetailsModalFunc(member),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: team.color.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              member.avatar,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                member.role,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF7F8C8D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getAccessColor(member.access).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            member.access,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _getAccessColor(member.access),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          member.timeInTeam,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: team.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        if (_memberMenuHover[index] == true)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.more_vert,
                                color: Color(0xFFBDC3C7),
                                size: 20,
                              ),
                              onSelected: (value) {},
                              itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'add_colleague',
                                  child: Text('Добавить в коллеги'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'share_link',
                                  child: Text('Поделиться ссылкой'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'details',
                                  child: Text('Подробности'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchModal() {
    return GestureDetector(
      onTap: _hideSearchModal,
      child: Container(
        color: Colors.black.withAlpha(128),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Поиск задач, подзадач, людей...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF5D7CF9)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE8EDF2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF5D7CF9)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (_taskSearchResults.isNotEmpty)
                          _buildSearchCategory(
                            title: 'Задачи',
                            icon: Icons.task,
                            results: _taskSearchResults,
                          ),
                        if (_taskSearchResults.isNotEmpty) const SizedBox(height: 16),
                        
                        if (_subtaskSearchResults.isNotEmpty)
                          _buildSearchCategory(
                            title: 'Подзадачи',
                            icon: Icons.subdirectory_arrow_right,
                            results: _subtaskSearchResults,
                          ),
                        if (_subtaskSearchResults.isNotEmpty) const SizedBox(height: 16),
                        
                        if (_peopleSearchResults.isNotEmpty)
                          _buildSearchCategory(
                            title: 'Люди',
                            icon: Icons.people,
                            results: _peopleSearchResults,
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _hideSearchModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D7CF9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Закрыть',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtaskSearchModal() {
    return GestureDetector(
      onTap: _hideSubtaskSearchModal,
      child: Container(
        color: Colors.black.withAlpha(128),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _selectedTask!.color.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.subdirectory_arrow_right,
                              color: _selectedTask!.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedSubtask!.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                                Text(
                                  'Подзадача задачи: ${_selectedTask!.name}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF7F8C8D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _hideSubtaskSearchModal,
                            icon: const Icon(Icons.close, color: Color(0xFF7F8C8D)),
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Статус',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedSubtask!.isCompleted
                                  ? const Color(0xFF4CAF50).withAlpha(25)
                                  : const Color(0xFF5D7CF9).withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _selectedSubtask!.isCompleted
                                      ? Icons.check_circle
                                      : Icons.access_time,
                                  color: _selectedSubtask!.isCompleted
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFF5D7CF9),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedSubtask!.isCompleted
                                        ? 'Подзадача завершена'
                                        : 'Подзадача активна',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Участники',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedSubtask!.participants.map((participant) {
                              return Chip(
                                label: Text(
                                  participant,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: const Color(0xFFE6EBFF),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _completeSubtask(_selectedTask!, _selectedSubtask!);
                            _hideSubtaskSearchModal();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _selectedSubtask!.isCompleted ? 'Подзадача завершена' : 'Завершить подзадачу',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _hideSubtaskSearchModal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8FAFD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFF5D7CF9)),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Вернуться к задаче',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF5D7CF9),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCategory({
    required String title,
    required IconData icon,
    required List<SearchResult> results,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF5D7CF9), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          ...results.map((result) => ListTile(
            leading: Icon(result.icon, color: const Color(0xFF5D7CF9)),
            title: Text(
              result.name,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF2C3E50),
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFBDC3C7)),
            onTap: () => _onSearchResultTap(result),
          )),
        ],
      ),
    );
  }

  Widget _buildCalendarModal() {
    return GestureDetector(
      onTap: _hideCalendarModal,
      child: Container(
        color: Colors.black.withAlpha(128),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: CalendarWidget(
                currentDate: _currentDate,
                onDateSelected: (date) {
                  _hideCalendarModal();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlowTimeHomePage(selectedDate: date),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateTeamModal() {
    return GestureDetector(
      onTap: _hideCreateTeamModal,
      child: Container(
        color: Colors.black.withAlpha(128),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Создать команду',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextField(
                        controller: _teamNameController,
                        decoration: InputDecoration(
                          labelText: 'Название команды',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE8EDF2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF5D7CF9)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextField(
                        controller: _telegramUsernameController,
                        decoration: InputDecoration(
                          labelText: 'Telegram username (без @)',
                          prefixText: '@',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE8EDF2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF5D7CF9)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6EBFF).withAlpha(76),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info, color: Color(0xFF5D7CF9), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Как это работает',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '1. Введите Telegram username\n'
                              '2. Бот отправит приглашение в Telegram\n'
                              '3. Пользователь подтверждает приглашение\n'
                              '4. Если у него есть аккаунт в приложении, он будет добавлен\n'
                              '5. Если аккаунта нет, он получит уведомление',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _hideCreateTeamModal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF8FAFD),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Color(0xFFE8EDF2)),
                              ),
                              child: Text(
                                'Отмена',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF7F8C8D),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_teamNameController.text.isNotEmpty && 
                                    _telegramUsernameController.text.isNotEmpty) {
                                  _inviteToTelegram(_telegramUsernameController.text);
                                  _hideCreateTeamModal();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Заполните все поля'),
                                      backgroundColor: Color(0xFF5D7CF9),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5D7CF9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                'Пригласить',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppSettingsModal() {
    List<AppUsage> allApps = [];
    for (var segment in _usageSegments) {
      for (var app in segment.apps) {
        allApps.add(app);
      }
    }
    
    allApps.sort((a, b) => a.name.compareTo(b.name));

    return GestureDetector(
      onTap: _hideAppSettingsModal,
      child: Container(
        color: Colors.black.withAlpha(128),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Настройки статистики',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Игнорируемые приложения не учитываются в статистике',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF7F8C8D),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: allApps.length,
                      itemBuilder: (context, index) {
                        final app = allApps[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(13),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  app.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => _toggleAppIgnore(app),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: app.isIgnored 
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFF44336),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  app.isIgnored ? 'Отменить' : 'Игнорировать',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _hideAppSettingsModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D7CF9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Сохранить',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskDetailsModal() {
    if (_selectedTask == null) return const SizedBox();
    
    return GestureDetector(
      onTap: _hideTaskDetailsModal,
      child: Container(
        color: Colors.black.withAlpha(128),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _selectedTask!.color.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.task,
                              color: _selectedTask!.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedTask!.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                                Text(
                                  _selectedTask!.type,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF7F8C8D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _hideTaskDetailsModal,
                            icon: const Icon(Icons.close, color: Color(0xFF7F8C8D)),
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedTask!.isCompleted
                              ? const Color(0xFF4CAF50).withAlpha(25)
                              : _selectedTask!.isCancelled
                                  ? const Color(0xFFF44336).withAlpha(25)
                                  : const Color(0xFF5D7CF9).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedTask!.isCompleted
                                  ? Icons.check_circle
                                  : _selectedTask!.isCancelled
                                      ? Icons.cancel
                                      : Icons.access_time,
                              color: _selectedTask!.isCompleted
                                  ? const Color(0xFF4CAF50)
                                  : _selectedTask!.isCancelled
                                      ? const Color(0xFFF44336)
                                      : const Color(0xFF5D7CF9),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedTask!.isCompleted
                                    ? 'Задача завершена'
                                    : _selectedTask!.isCancelled
                                        ? 'Задача отменена'
                                        : 'Задача активна',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Время выполнения',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildTimeChip(
                                'Начало',
                                DateFormat('dd.MM.yyyy HH:mm').format(_selectedTask!.startDate),
                              ),
                              const SizedBox(width: 12),
                              _buildTimeChip(
                                'Окончание',
                                DateFormat('dd.MM.yyyy HH:mm').format(_selectedTask!.endDate),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Подзадачи',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          if (_selectedTask!.subtasks.isEmpty)
                            Text(
                              'Нет подзадач',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF7F8C8D),
                              ),
                            )
                          else
                            ..._selectedTask!.subtasks.map((subtask) {
                              return GestureDetector(
                                onTap: () => _onSubtaskTap(_selectedTask!, subtask),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _selectedSubtask?.id == subtask.id
                                        ? const Color(0xFF5D7CF9).withAlpha(25)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _selectedSubtask?.id == subtask.id
                                          ? const Color(0xFF5D7CF9)
                                          : const Color(0xFFE8EDF2),
                                      width: _selectedSubtask?.id == subtask.id ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(13),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: subtask.isCompleted,
                                        onChanged: !_selectedTask!.isCompleted && !_selectedTask!.isCancelled
                                            ? (value) => _completeSubtask(_selectedTask!, subtask)
                                            : null,
                                        activeColor: const Color(0xFF5D7CF9),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              subtask.name,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF2C3E50),
                                              ),
                                            ),
                                            if (subtask.participants.isNotEmpty)
                                              Text(
                                                'Участники: ${subtask.participants.join(', ')}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: const Color(0xFF7F8C8D),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    if (_selectedTask!.participants.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Участники',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedTask!.participants.map((participant) {
                                return Chip(
                                  label: Text(
                                    participant,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFFE6EBFF),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    if (!_selectedTask!.isCompleted && !_selectedTask!.isCancelled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Продлить задачу',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C3E50),
                            ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _extensionMinutes.length,
                                itemBuilder: (context, index) {
                                  final minutes = _extensionMinutes[index];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedExtension = minutes;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedExtension == minutes
                                            ? const Color(0xFF5D7CF9)
                                            : const Color(0xFFE6EBFF),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '+$minutes мин',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: _selectedExtension == minutes
                                                ? Colors.white
                                                : const Color(0xFF2C3E50),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _extendTask(_selectedTask!, _selectedExtension),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5D7CF9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: Text(
                                'Продлить на $_selectedExtension минут',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    if (!_selectedTask!.isCompleted && !_selectedTask!.isCancelled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _completeTask(_selectedTask!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  'Завершить задачу',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _cancelTask(_selectedTask!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF44336),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  'Отменить задачу',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    if (_selectedTask!.isCompleted || _selectedTask!.isCancelled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _hideTaskDetailsModal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF8FAFD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFF5D7CF9)),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Вернуться к списку',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF5D7CF9),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(String label, String time) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberDetailsModal() {
    final member = TeamMember(
      name: 'Алихан',
      role: 'Frontend Dev',
      access: 'Админ',
      timeInTeam: '45 дней',
      avatar: '👨‍💻',
      gender: 'male',
      teams: ['AITU', 'TechLab'],
      assignedTasks: [],
    );

    return GestureDetector(
      onTap: _hideMemberDetailsModal,
      child: Container(
        color: Colors.black.withAlpha(128),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5D7CF9).withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                member.avatar,
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            member.name,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            member.role,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF7F8C8D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getAccessColor(member.access).withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              member.access,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getAccessColor(member.access),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Состоит в командах',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...member.teams.map((team) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF5D7CF9),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      team,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF2C3E50),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      member.timeInTeam,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: const Color(0xFF7F8C8D),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Назначенные подзадачи',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C3E50),
                            ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Нет назначенных подзадач',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _addToFriends(member),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D7CF9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Добавить в друзья',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _hideMemberDetailsModal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8FAFD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE8EDF2)),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Закрыть',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF7F8C8D),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getAccessColor(String access) {
    switch (access) {
      case 'Админ':
        return const Color(0xFFF44336);
      case 'Редактор':
        return const Color(0xFFFF9800);
      case 'Просмотр':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  BorderRadius _getSegmentBorderRadius(int index) {
    if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(6),
        bottomLeft: Radius.circular(6),
      );
    } else if (index == _usageSegments.length - 1) {
      return const BorderRadius.only(
        topRight: Radius.circular(6),
        bottomRight: Radius.circular(6),
      );
    }
    return BorderRadius.zero;
  }
}

class _SemicircleClockPainter extends CustomPainter {
  final List<Task> tasks;
  final int currentTaskIndex;
  final int? selectedTaskIndex;
  final Function(int) onTaskTap;

  const _SemicircleClockPainter({
    required this.tasks,
    required this.currentTaskIndex,
    this.selectedTaskIndex,
    required this.onTaskTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 70); // Центр смещен вверх
    final radius = size.width * 0.35; // Уменьшен радиус
    
    // Фон полукруга
    final backgroundPaint = Paint()
      ..color = const Color(0xFFF8FAFD)
      ..style = PaintingStyle.fill;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, // Начальный угол: 0 радиан (справа)
      pi, // Конечный угол: π радиан (слева)
      true, // Заполненный
      backgroundPaint,
    );
    
    // Граница полукруга
    final borderPaint = Paint()
      ..color = const Color(0xFFE8EDF2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      pi,
      false,
      borderPaint,
    );
    
    // Точки на циферблате (только верхний полукруг)
    for (int i = 0; i <= 96; i++) {
      double hour = i / 4.0;
      double angle = pi * hour / 24.0;
      
      bool isMajorPoint = i % 16 == 0; // Каждые 4 часа
      bool isMediumPoint = i % 8 == 0; // Каждые 2 часа
      
      double pointRadius;
      Color pointColor;
      
      if (isMajorPoint) {
        pointRadius = 2.5;
        pointColor = const Color(0xFF2C3E50);
      } else if (isMediumPoint) {
        pointRadius = 1.5;
        pointColor = const Color(0xFF95A5A6);
      } else {
        pointRadius = 1.0;
        pointColor = const Color(0xFFBDC3C7);
      }
      
      double pointX = center.dx + radius * cos(angle);
      double pointY = center.dy + radius * sin(angle);
      
      final pointPaint = Paint()
        ..color = pointColor
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(pointX, pointY), pointRadius, pointPaint);
    }
    
    // Отрисовка задач как сегментов на полукруге
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final startAngle = pi * task.startHour / 24.0;
      final endAngle = pi * task.endHour / 24.0;
      final sweepAngle = endAngle - startAngle;
      
      bool isCurrent = i == currentTaskIndex;
      bool isSelected = i == selectedTaskIndex;
      
      final taskPaint = Paint()
        ..color = isSelected
            ? task.color.withOpacity(0.8)
            : isCurrent
                ? task.color
                : task.color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 10 : (isCurrent ? 8 : 5)
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 15),
        startAngle,
        sweepAngle,
        false,
        taskPaint,
      );
      
      if (isCurrent || isSelected) {
        final innerPaint = Paint()
          ..color = task.color.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - 10),
          startAngle,
          sweepAngle,
          false,
          innerPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CalendarWidget extends StatefulWidget {
  final DateTime currentDate;
  final Function(DateTime) onDateSelected;
  
  const CalendarWidget({
    super.key,
    required this.currentDate,
    required this.onDateSelected,
  });
  
  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentMonth;
  
  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.currentDate.year, widget.currentDate.month, 1);
  }
  
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }
  
  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }
  
  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    
    List<DateTime> days = [];
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }
    
    final firstWeekday = firstDay.weekday;
    for (int i = 1; i < firstWeekday; i++) {
      days.insert(0, DateTime(_currentMonth.year, _currentMonth.month, 0));
    }
    
    return days;
  }
  
  double _getProgressForDay(DateTime day) {
    final random = Random(day.millisecondsSinceEpoch);
    return random.nextDouble();
  }
  
  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy', 'ru').format(_currentMonth);
    final capitalizedMonthName = monthName[0].toUpperCase() + monthName.substring(1);
    final daysInMonth = _getDaysInMonth();
    const weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.keyboard_arrow_left, color: Color(0xFF5D7CF9)),
              ),
              const SizedBox(width: 16),
              Text(
                capitalizedMonthName,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.keyboard_arrow_right, color: Color(0xFF5D7CF9)),
              ),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: weekdays.map((day) {
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7F8C8D),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth.length,
            itemBuilder: (context, index) {
              final day = daysInMonth[index];
              
              if (day.month != _currentMonth.month) {
                return const SizedBox.shrink();
              }
              
              final progress = _getProgressForDay(day);
              final isToday = day.day == DateTime.now().day && 
                             day.month == DateTime.now().month && 
                             day.year == DateTime.now().year;
              
              return GestureDetector(
                onTap: () => widget.onDateSelected(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isToday ? const Color(0xFF5D7CF9) : const Color(0xFFE8EDF2),
                      width: isToday ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF5D7CF9).withOpacity(progress),
                                const Color(0xFF5D7CF9).withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      Center(
                        child: Text(
                          day.day.toString().padLeft(2, '0'),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                            color: isToday ? const Color(0xFF5D7CF9) : const Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D7CF9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Закрыть',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}