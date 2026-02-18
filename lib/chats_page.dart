import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_detail_page.dart';
import 'models/chat_models.dart';
import 'home_page.dart';
import 'recommendations_page.dart';
import 'profile_page.dart';
import 'task_creation_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _searchMode = false;
  String _searchQuery = '';
  
  // НАВИГАЦИОННЫЙ ИНДЕКС
  int _currentNavIndex = 3;
  
  final List<Chat> _allChats = [
    Chat(
      id: '1',
      name: 'Athalia Putri',
      participants: [
        ChatUser(
          id: 'user1',
          name: 'Athalia Putri',
          avatar: 'AP',
          status: 'Product Designer',
          isOnline: true,
          lastSeen: 'только что',
          color: const Color(0xFF5D7CF9),
        ),
      ],
      lastMessage: ChatMessage(
        id: 'm1',
        chatId: '1',
        senderId: 'user1',
        text: 'Good morning, did you sleep well?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      unreadCount: 0,
      isPinned: true,
      lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Chat(
      id: '2',
      name: 'Raki Devon',
      participants: [
        ChatUser(
          id: 'user2',
          name: 'Raki Devon',
          avatar: 'RD',
          status: 'Frontend Developer',
          isOnline: false,
          lastSeen: '2 часа назад',
          color: const Color(0xFF4AC0C2),
        ),
      ],
      lastMessage: ChatMessage(
        id: 'm2',
        chatId: '2',
        senderId: 'user2',
        text: 'How is it going?',
        timestamp: DateTime(2024, 6, 17, 14, 30),
        isRead: true,
      ),
      unreadCount: 0,
      lastActivity: DateTime(2024, 6, 17, 14, 30),
    ),
    Chat(
      id: '3',
      name: 'Erlan Sadewa',
      participants: [
        ChatUser(
          id: 'user3',
          name: 'Erlan Sadewa',
          avatar: 'ES',
          status: 'Backend Developer',
          isOnline: false,
          lastSeen: '5 часов назад',
          color: const Color(0xFFFF9A6A),
        ),
      ],
      lastMessage: ChatMessage(
        id: 'm3',
        chatId: '3',
        senderId: 'me',
        text: 'Aight, noted',
        timestamp: DateTime(2024, 6, 17, 10, 15),
        isRead: true,
      ),
      unreadCount: 0,
      lastActivity: DateTime(2024, 6, 17, 10, 15),
    ),
    Chat(
      id: '4',
      name: 'TechLab Team',
      participants: [
        ChatUser(
          id: 'user4',
          name: 'Асылхан',
          avatar: 'А',
          status: 'ML Engineer',
          isOnline: true,
          lastSeen: 'только что',
          color: const Color(0xFF7B6CF2),
        ),
        ChatUser(
          id: 'user5',
          name: 'Дина',
          avatar: 'Д',
          status: 'Data Scientist',
          isOnline: false,
          lastSeen: '30 мин назад',
          color: const Color(0xFF66BB6A),
        ),
      ],
      lastMessage: ChatMessage(
        id: 'm4',
        chatId: '4',
        senderId: 'user4',
        text: 'Завтра в 10:00 созвон по новому проекту. Подготовьте презентации.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isRead: false,
      ),
      unreadCount: 3,
      type: ChatType.group,
      lastActivity: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    Chat(
      id: '5',
      name: 'DesignHub',
      participants: [
        ChatUser(
          id: 'user6',
          name: 'Аружан',
          avatar: 'А',
          status: 'Product Designer',
          isOnline: true,
          lastSeen: 'только что',
          color: const Color(0xFFFF6B6B),
        ),
      ],
      lastMessage: ChatMessage(
        id: 'm5',
        chatId: '5',
        senderId: 'user6',
        text: 'Отправил тебе новые макеты для ревью',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        type: MessageType.document,
        fileName: 'design_mockups.fig',
        fileSize: 24.5,
      ),
      unreadCount: 2,
      lastActivity: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<Chat> get _filteredChats {
    if (_searchQuery.isEmpty) {
      final pinned = _allChats.where((c) => c.isPinned).toList();
      final unpinned = _allChats.where((c) => !c.isPinned).toList();
      return [...pinned, ...unpinned];
    }
    return _allChats.where((chat) {
      return chat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          chat.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openChat(Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(chat: chat),
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _searchMode = !_searchMode;
      if (!_searchMode) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
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
        // Уже на чатах
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Column(
        children: [
          // Аппбар с поиском
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        if (_searchMode)
                          IconButton(
                            onPressed: _toggleSearch,
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
                          ),
                        
                        Expanded(
                          child: _searchMode
                              ? TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Поиск...',
                                    hintStyle: GoogleFonts.inter(
                                      color: const Color(0xFFBDC3C7),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF2C3E50),
                                  ),
                                )
                              : Text(
                                  'Сообщения',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                        ),
                        
                        IconButton(
                          onPressed: _toggleSearch,
                          icon: Icon(
                            _searchMode ? Icons.close : Icons.search,
                            color: const Color(0xFF5D7CF9),
                          ),
                        ),
                        
                        if (!_searchMode)
                          IconButton(
                            onPressed: () {
                              // Открыть меню
                            },
                            icon: const Icon(
                              Icons.more_vert,
                              color: Color(0xFF5D7CF9),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Табы
                if (!_searchMode)
                  Container(
                    height: 48,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF5D7CF9),
                      unselectedLabelColor: const Color(0xFF7F8C8D),
                      indicatorColor: const Color(0xFF5D7CF9),
                      tabs: [
                        Tab(
                          child: Text(
                            'Все',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Команды',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Список чатов
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Все чаты
                _buildChatsList(_filteredChats),
                
                // Команды
                _buildChatsList(
                  _allChats.where((c) => c.type == ChatType.group).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Кнопка нового сообщения
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Открыть диалог нового сообщения
          _showNewChatDialog();
        },
        backgroundColor: const Color(0xFF5D7CF9),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      
      // НАВИГАЦИОННАЯ ПАНЕЛЬ КАК В home_page.dart
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

  Widget _buildChatsList(List<Chat> chats) {
    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: const Color(0xFFE8EDF2),
            ),
            const SizedBox(height: 16),
            Text(
              'Нет сообщений',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF7F8C8D),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return _buildChatItem(chat);
      },
    );
  }

  Widget _buildChatItem(Chat chat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openChat(chat),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Аватар
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: chat.participants.first.color.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          chat.participants.first.avatar,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: chat.participants.first.color,
                          ),
                        ),
                      ),
                    ),
                    
                    // Онлайн статус
                    if (chat.participants.first.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    
                    // Количество участников для групп
                    if (chat.type == ChatType.group)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF5D7CF9),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat.participants.length.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // Информация о чате
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          
                          Text(
                            chat.timeSubtitle,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF7F8C8D),
                              ),
                              maxLines: 1,
                            ),
                          ),
                          
                          if (chat.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5D7CF9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                chat.unreadCount.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      // Статус для последнего сообщения
                      if (chat.lastMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              if (chat.lastMessage!.senderId == 'me')
                                const Icon(
                                  Icons.done_all,
                                  size: 14,
                                  color: Color(0xFF5D7CF9),
                                ),
                              
                              if (chat.lastMessage!.senderId == 'me')
                                const SizedBox(width: 4),
                              
                              if (chat.lastMessage!.isEdited)
                                Text(
                                  'ред.',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF7F8C8D),
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
          ),
        ),
      ),
    );
  }

  void _showNewChatDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EDF2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Новое сообщение',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                decoration: InputDecoration(
                  hintText: 'Поиск контактов...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF5D7CF9)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFD),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Недавние контакты',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Список контактов
              SizedBox(
                height: 200,
                child: ListView(
                  children: [
                    _buildContactItem('Athalia Putri', 'Product Designer', true),
                    _buildContactItem('Raki Devon', 'Frontend Developer', false),
                    _buildContactItem('Erlan Sadewa', 'Backend Developer', false),
                    _buildContactItem('TechLab Team', '3 участника', true),
                    _buildContactItem('DesignHub', 'Дизайн команда', true),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactItem(String name, String subtitle, bool isOnline) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF5D7CF9).withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 2),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5D7CF9),
                    ),
                  ),
                ),
              ),
              
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.message,
              color: Color(0xFF5D7CF9),
            ),
          ),
        ],
      ),
    );
  }
}

class Badge extends StatelessWidget {
  final Widget? label;
  final Widget child;
  
  const Badge({
    super.key,
    this.label,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (label != null)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B6B),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: label,
              ),
            ),
          ),
      ],
    );
  }
}