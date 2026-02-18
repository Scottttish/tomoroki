// lib/services/recommendations_service.dart
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import '../supabase_client.dart';

class RecommendationsService {
  final supabase_flutter.SupabaseClient _supabase = supabase;

  Future<List<Map<String, dynamic>>> getRecommendations(String userId) async {
    try {
      final response = await _supabase
          .from('recommendations')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .order('priority', ascending: true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Get recommendations error: $e');
      throw Exception('Failed to get recommendations');
    }
  }

  Future<void> markRecommendationCompleted(String recommendationId) async {
    try {
      await _supabase
          .from('recommendations')
          .update({
            'is_completed': true,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', recommendationId);
    } catch (e) {
      log('Mark recommendation completed error: $e');
      throw Exception('Failed to mark recommendation completed');
    }
  }

  Future<void> createRecommendation({
    required String userId,
    required String title,
    required String description,
    required String category,
    String priority = 'low',
    String? actionType,
    Map<String, dynamic>? actionData,
  }) async {
    try {
      await _supabase
          .from('recommendations')
          .insert({
            'user_id': userId,
            'title': title,
            'description': description,
            'category': category,
            'priority': priority,
            'action_type': actionType,
            'action_data': actionData ?? {},
          });
    } catch (e) {
      log('Create recommendation error: $e');
      throw Exception('Failed to create recommendation');
    }
  }

  Future<void> generateSmartRecommendations(String userId) async {
    try {
      final today = DateTime.now();
      final weekAgo = today.subtract(const Duration(days: 7));

      final efficiencyStats = await _supabase
          .from('efficiency_stats')
          .select()
          .eq('user_id', userId)
          .gte('date', weekAgo.toIso8601String().split('T')[0])
          .order('date', ascending: false);

      final appStats = await _supabase
          .from('app_statistics')
          .select()
          .eq('user_id', userId)
          .gte('usage_date', weekAgo.toIso8601String().split('T')[0])
          .order('usage_date', ascending: false);

      final tasks = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .gte('created_at', weekAgo.toIso8601String())
          .order('created_at', ascending: false);

      if (efficiencyStats.isNotEmpty) {
        final latestStats = efficiencyStats[0] as Map<String, dynamic>;
        final totalScore = (latestStats['total_score'] as num?)?.toInt() ?? 0;

        if (totalScore < 60) {
          await createRecommendation(
            userId: userId,
            title: 'Низкая эффективность',
            description: 'Ваша эффективность за последние дни ниже среднего. Попробуйте технику Pomodoro.',
            category: 'productivity',
            priority: 'high',
            actionType: 'task',
            actionData: {
              'technique': 'pomodoro',
              'duration': 25,
            },
          );
        }
      }

      if (appStats.isNotEmpty) {
        final totalUsage = appStats.fold<int>(0, (int sum, stat) {
          final usageTime = (stat as Map<String, dynamic>)['total_usage_time'] as int?;
          return sum + (usageTime ?? 0);
        });

        if (totalUsage > 480) {
          await createRecommendation(
            userId: userId,
            title: 'Много времени в приложениях',
            description: 'Вы провели более 8 часов в приложениях. Сделайте перерыв.',
            category: 'health',
            priority: 'medium',
            actionType: 'reminder',
            actionData: {
              'message': 'Время сделать перерыв!',
              'interval': 60,
            },
          );
        }
      }

      if (tasks.isNotEmpty) {
        final incompleteTasks = tasks.where((task) {
          final taskMap = task as Map<String, dynamic>;
          return taskMap['status'] != 'done';
        }).length;

        if (incompleteTasks > 5) {
          await createRecommendation(
            userId: userId,
            title: 'Много незавершенных задач',
            description: 'У вас $incompleteTasks незавершенных задач. Попробуйте приоритизировать их.',
            category: 'time_management',
            priority: 'medium',
            actionType: 'task',
            actionData: {
              'action': 'prioritize_tasks',
              'count': incompleteTasks,
            },
          );
        }
      }
    } catch (e) {
      log('Generate smart recommendations error: $e');
    }
  }
}