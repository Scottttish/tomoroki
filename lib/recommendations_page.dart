import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'chats_page.dart';
import 'profile_page.dart';
import 'task_creation_page.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  final List<DelayPattern> _delayPatterns = [
    DelayPattern(day: 'Пн', delayMinutes: 5, pattern: 'ровно'),
    DelayPattern(day: 'Вт', delayMinutes: 15, pattern: 'лёгкое'),
    DelayPattern(day: 'Ср', delayMinutes: 45, pattern: 'сильное'),
    DelayPattern(day: 'Чт', delayMinutes: 25, pattern: 'лёгкое'),
    DelayPattern(day: 'Пт', delayMinutes: 35, pattern: 'среднее'),
    DelayPattern(day: 'Сб', delayMinutes: 120, pattern: 'полный'),
    DelayPattern(day: 'Вс', delayMinutes: 90, pattern: 'среднее'),
  ];

  final List<String> _timePeriods = [
    '00-03',
    '03-06',
    '06-09',
    '09-12',
    '12-15',
    '15-18',
    '18-21',
    '21-24'
  ];

  final List<String> _daysOfWeek = [
    'ПН',
    'ВТ',
    'СР',
    'ЧТ',
    'ПТ',
    'СБ',
    'ВС'
  ];

  final List<String> _focusLevels = [
    '0 мин',
    '1-10 мин',
    '10-30 мин',
    '30-60 мин',
    '60+ мин'
  ];

  final List<String> _focusTimes = [
    '06:00',
    '09:00',
    '12:00',
    '15:00',
    '18:00',
    '21:00'
  ];

  // НАВИГАЦИОННЫЙ ИНДЕКС
  int _currentNavIndex = 1;

  // Генерация случайных данных для тепловой карты опозданий
  List<List<double>> _generateDelayData() {
    final random = Random();
    List<List<double>> data = [];
    
    for (int day = 0; day < 7; day++) {
      List<double> row = [];
      for (int period = 0; period < 8; period++) {
        // Базовый уровень опозданий
        double baseDelay;
        
        // Утро: меньше опозданий
        if (period == 2) baseDelay = 5 + random.nextDouble() * 10; // 06-09
        else if (period == 3) baseDelay = 10 + random.nextDouble() * 15; // 09-12
        // День: больше опозданий
        else if (period == 4) baseDelay = 20 + random.nextDouble() * 25; // 12-15
        else if (period == 5) baseDelay = 25 + random.nextDouble() * 30; // 15-18
        // Вечер: самые большие опоздания
        else if (period == 6) baseDelay = 40 + random.nextDouble() * 40; // 18-21
        else if (period == 7) baseDelay = 60 + random.nextDouble() * 60; // 21-24
        else baseDelay = random.nextDouble() * 5; // Ночью
        
        // Пятница и суббота - больше опозданий
        if (day == 4 || day == 5) baseDelay *= 1.5;
        
        row.add(baseDelay);
      }
      data.add(row);
    }
    
    return data;
  }

  // Генерация данных для плотности фокуса
  List<List<double>> _generateFocusData() {
    final random = Random();
    List<List<double>> data = [];
    
    // 6 временных слотов x 5 уровней фокуса
    for (int timeSlot = 0; timeSlot < 6; timeSlot++) {
      List<double> row = [];
      for (int level = 0; level < 5; level++) {
        double value = 0.0;
        
        // Утром больше длинных сессий
        if (timeSlot == 0) { // 06:00
          if (level == 4) value = 0.7 + random.nextDouble() * 0.3; // 60+ мин
          else if (level == 3) value = 0.5 + random.nextDouble() * 0.2; // 30-60 мин
          else value = random.nextDouble() * 0.3;
        }
        // Днем средние сессии
        else if (timeSlot == 2) { // 12:00
          if (level == 2) value = 0.6 + random.nextDouble() * 0.3; // 10-30 мин
          else if (level == 3) value = 0.4 + random.nextDouble() * 0.2; // 30-60 мин
          else value = random.nextDouble() * 0.4;
        }
        // Вечером короткие сессии
        else if (timeSlot == 5) { // 21:00
          if (level == 1) value = 0.8 + random.nextDouble() * 0.2; // 1-10 мин
          else value = random.nextDouble() * 0.3;
        }
        // Остальное время
        else {
          value = random.nextDouble();
          // Уменьшаем вероятность длинных сессий
          if (level >= 3) value *= 0.5;
        }
        
        row.add(value);
      }
      data.add(row);
    }
    
    return data;
  }

  Color _getDelayColor(double delayMinutes) {
    double opacity;
    if (delayMinutes < 10) {
      opacity = 0.3;
    } else if (delayMinutes < 30) {
      opacity = 0.5 + ((delayMinutes - 10) / 40);
    } else if (delayMinutes < 60) {
      opacity = 0.6 + ((delayMinutes - 30) / 60);
    } else {
      opacity = 0.7 + ((delayMinutes - 60) / 120);
    }
    // Ограничиваем opacity между 0.0 и 1.0
    opacity = opacity.clamp(0.0, 1.0);
    return const Color(0xFFF44336).withOpacity(opacity);
  }

  Color _getFocusColor(double intensity) {
    double opacity;
    if (intensity < 0.2) {
      opacity = 0.1;
    } else if (intensity < 0.4) {
      opacity = 0.3;
    } else if (intensity < 0.6) {
      opacity = 0.5;
    } else if (intensity < 0.8) {
      opacity = 0.7;
    } else {
      opacity = 0.9;
    }
    // Ограничиваем opacity между 0.0 и 1.0
    opacity = opacity.clamp(0.0, 1.0);
    return const Color(0xFF5D7CF9).withOpacity(opacity);
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
        // Уже на рекомендациях
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final delayData = _generateDelayData();
    final focusData = _generateFocusData();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: CustomScrollView(
        slivers: [
          // Заголовок страницы
          SliverAppBar(
            backgroundColor: const Color(0xFFF8FAFD),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            title: Text(
              'Рекомендации',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2C3E50),
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: false,
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
          
          // Блок ритма опозданий
          SliverToBoxAdapter(
            child: _buildDelayHeatmap(delayData),
          ),
          
          // Блок плотности фокуса
          SliverToBoxAdapter(
            child: _buildFocusHeatmap(focusData),
          ),
          
          // Тренд эффективности
          SliverToBoxAdapter(
            child: _buildEfficiencyTrend(),
          ),
          
          // Сводка
          SliverToBoxAdapter(
            child: _buildSummary(),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
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

  Widget _buildDelayHeatmap(List<List<double>> data) {
    final maxDelay = data.expand((row) => row).reduce(max);
    
    return Container(
      margin: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: Color(0xFF5D7CF9)),
              const SizedBox(width: 12),
              Text(
                'Ритм опозданий',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Среднее опоздание окончания задач (в минутах)',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Легенда
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildLegendItem(const Color(0xFF4CAF50), '0-10 мин'),
                _buildLegendItem(const Color(0xFFFFC107), '10-30 мин'),
                _buildLegendItem(const Color(0xFFFF9800), '30-60 мин'),
                _buildLegendItem(const Color(0xFFF44336), '60+ мин'),
              ],
            ),
          ),
          
          // Тепловая карта
          Column(
            children: [
              // Заголовки времени
              Row(
                children: [
                  const SizedBox(width: 60), // Отступ для дней
                  ..._timePeriods.map((period) {
                    return Expanded(
                      child: Text(
                        period,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7F8C8D),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Сама карта
              ...List.generate(7, (dayIndex) {
                return Row(
                  children: [
                    // Метка дня
                    SizedBox(
                      width: 60,
                      child: Text(
                        _daysOfWeek[dayIndex],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                    
                    // Ячейки опозданий
                    ...List.generate(8, (periodIndex) {
                      final delay = data[dayIndex][periodIndex];
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          height: 36,
                          decoration: BoxDecoration(
                            color: _getDelayColor(delay),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${delay.round()}',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: delay > 30 ? Colors.white : const Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Выводы
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6EBFF).withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5D7CF9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.insights,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Самые проблемные периоды:',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Пятница и суббота вечером, среднее опоздание 45-90 минут',
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
        ],
      ),
    );
  }

  Widget _buildFocusHeatmap(List<List<double>> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, color: Color(0xFF5D7CF9)),
              const SizedBox(width: 12),
              Text(
                'Плотность непрерывной работы',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Частота разных длительностей непрерывной работы по времени суток',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Тепловая карта
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Вертикальная ось (уровни фокуса)
              Column(
                children: [
                  const SizedBox(height: 20),
                  ..._focusLevels.map((level) {
                    return Container(
                      height: 40,
                      width: 80,
                      margin: const EdgeInsets.only(bottom: 2),
                      child: Center(
                        child: Text(
                          level,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7F8C8D),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              
              Expanded(
                child: Column(
                  children: [
                    // Горизонтальная ось (время)
                    Row(
                      children: _focusTimes.map((time) {
                        return Expanded(
                          child: Text(
                            time,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7F8C8D),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Сама тепловая карта
                    ...List.generate(5, (levelIndex) {
                      return Row(
                        children: List.generate(6, (timeIndex) {
                          final intensity = data[timeIndex][levelIndex];
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getFocusColor(intensity),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${(intensity * 100).toInt()}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: intensity > 0.5 
                                        ? Colors.white 
                                        : const Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Легенда
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFocusLegendItem(0.1, 'Редко'),
              _buildFocusLegendItem(0.3, 'Иногда'),
              _buildFocusLegendItem(0.5, 'Часто'),
              _buildFocusLegendItem(0.7, 'Обычно'),
              _buildFocusLegendItem(0.9, 'Всегда'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Выводы
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6EBFF).withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5D7CF9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Пик продуктивности: 30-60 минут непрерывной работы в утренние часы',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Вечером работа прерывается каждые 1-10 минут',
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
        ],
      ),
    );
  }

  Widget _buildEfficiencyTrend() {
    final trendData = List.generate(10, (index) {
      return 70 + Random().nextInt(30);
    });
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF5D7CF9)),
              const SizedBox(width: 12),
              Text(
                'Динамика эффективности',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Изменение показателя за последние 10 дней',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // График
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: EfficiencyTrendPainter(data: trendData),
              child: Container(),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Показатели
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem('Начало', '${trendData.first}%', const Color(0xFF4CAF50)),
              _buildMetricItem('Сейчас', '${trendData.last}%', const Color(0xFF5D7CF9)),
              _buildMetricItem('Рост', '+${trendData.last - trendData.first}%', const Color(0xFFFF9800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ключевые инсайты',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2C3E50),
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildInsightItem(
            icon: Icons.wb_sunny,
            color: const Color(0xFFFFC107),
            title: 'Утро — ваше сильное время',
            description: 'С 6 до 9 утра вы показываете самую высокую эффективность и минимальные опоздания.',
          ),
          
          const SizedBox(height: 16),
          
          _buildInsightItem(
            icon: Icons.schedule,
            color: const Color(0xFFFF6B6B),
            title: 'Вечерние опоздания',
            description: 'После 18:00 задачи завершаются в среднем на 45 минут позже запланированного.',
          ),
          
          const SizedBox(height: 16),
          
          _buildInsightItem(
            icon: Icons.timelapse,
            color: const Color(0xFF4AC0C2),
            title: 'Непрерывная работа',
            description: 'Утром вы способны работать 30-60 минут без перерывов, к вечеру этот показатель падает до 1-10 минут.',
          ),
          
          const SizedBox(height: 16),
          
          _buildInsightItem(
            icon: Icons.trending_up,
            color: const Color(0xFF4CAF50),
            title: 'Стабильный рост',
            description: 'За последние 10 дней общая эффективность выросла на 12%.',
          ),
          
          const SizedBox(height: 24),
          
          // Основная рекомендация
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF5D7CF9).withOpacity(0.1),
                  const Color(0xFF7B6CF2).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF5D7CF9).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5D7CF9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Главная рекомендация',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Переносите самые сложные задачи на утренние часы (6:00-9:00). '
                  'Используйте это время для глубокой работы, а во второй половине дня '
                  'планируйте рутинные задачи и встречи.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF7F8C8D),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildFocusLegendItem(double opacity, String text) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF5D7CF9).withOpacity(opacity),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: const Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF7F8C8D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF7F8C8D),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EfficiencyTrendPainter extends CustomPainter {
  final List<int> data;

  EfficiencyTrendPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5D7CF9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF5D7CF9).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = const Color(0xFF5D7CF9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    final path = Path();
    final fillPath = Path();

    final widthStep = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final value = data[i];
      final normalizedValue = (value - minValue) / range;
      final x = i * widthStep;
      final y = size.height - (normalizedValue * size.height * 0.8) - 20;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Точки
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 5, dotBorderPaint);

      // Подписи значений
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$value%',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF7F8C8D),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - 10, y - 20));
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final gridPaint = Paint()
      ..color = const Color(0xFFE8EDF2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = size.height - (i * size.height / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DelayPattern {
  final String day;
  final int delayMinutes;
  final String pattern;

  DelayPattern({
    required this.day,
    required this.delayMinutes,
    required this.pattern,
  });
}