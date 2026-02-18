// lib/services/statistics_service.dart
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import '../supabase_client.dart';

class StatisticsService {
  final supabase_flutter.SupabaseClient _supabase = supabase;

  Future<void> recordAppUsage({
    required String userId,
    required String appName,
    String? category,
    int launchCount = 1,
    int totalUsageTime = 0,
    List<Map<String, dynamic>> usageIntervals = const [],
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final existingRecord = await _supabase
          .from('app_statistics')
          .select()
          .eq('user_id', userId)
          .eq('app_name', appName)
          .eq('usage_date', today);

      if (existingRecord.isNotEmpty && existingRecord[0] != null) {
        final record = existingRecord[0] as Map<String, dynamic>;
        await _supabase
            .from('app_statistics')
            .update({
              'launch_count': (record['launch_count'] as int? ?? 0) + launchCount,
              'total_usage_time': (record['total_usage_time'] as int? ?? 0) + totalUsageTime,
              'usage_intervals': [...(record['usage_intervals'] as List<dynamic>? ?? []), ...usageIntervals],
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', record['id']);
      } else {
        await _supabase
            .from('app_statistics')
            .insert({
              'user_id': userId,
              'app_name': appName,
              'category': category,
              'usage_date': today,
              'launch_count': launchCount,
              'total_usage_time': totalUsageTime,
              'usage_intervals': usageIntervals,
            });
      }
    } catch (e) {
      log('Record app usage error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAppStatistics(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    try {
      final query = _supabase
          .from('app_statistics')
          .select()
          .eq('user_id', userId);

      if (startDate != null) {
        query.gte('usage_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query.lte('usage_date', endDate.toIso8601String().split('T')[0]);
      }

      if (category != null) {
        query.eq('category', category);
      }

      query.order('usage_date', ascending: false);

      final response = await query;
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      log('Get app statistics error: $e');
      throw Exception('Failed to get app statistics');
    }
  }

  Future<void> recordEfficiencyStats({
    required String userId,
    int? focusScore,
    int? productivityScore,
    int? qualityScore,
    int? adaptabilityScore,
    int? totalScore,
    int taskCount = 0,
    int completedTasks = 0,
    int delayMinutes = 0,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      await _supabase
          .from('efficiency_stats')
          .upsert({
            'user_id': userId,
            'date': today,
            'focus_score': focusScore,
            'productivity_score': productivityScore,
            'quality_score': qualityScore,
            'adaptability_score': adaptabilityScore,
            'total_score': totalScore,
            'task_count': taskCount,
            'completed_tasks': completedTasks,
            'delay_minutes': delayMinutes,
            'created_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id,date');
    } catch (e) {
      log('Record efficiency stats error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEfficiencyStats(
    String userId, {
    int days = 7,
  }) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      
      final response = await _supabase
          .from('efficiency_stats')
          .select()
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .order('date', ascending: true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      log('Get efficiency stats error: $e');
      throw Exception('Failed to get efficiency stats');
    }
  }

  Future<Map<String, dynamic>> getDailyStats(String userId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      final appStats = await _supabase
          .from('app_statistics')
          .select()
          .eq('user_id', userId)
          .eq('usage_date', dateStr);

      final efficiencyStatsResponse = await _supabase
          .from('efficiency_stats')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .maybeSingle();

      final Map<String, dynamic>? efficiencyStats;
      if (efficiencyStatsResponse != null && efficiencyStatsResponse is Map<String, dynamic>) {
        efficiencyStats = efficiencyStatsResponse;
      } else {
        efficiencyStats = null;
      }

      final tasks = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .gte('created_at', '${dateStr}T00:00:00')
          .lte('created_at', '${dateStr}T23:59:59');

      return {
        'app_statistics': (appStats as List).cast<Map<String, dynamic>>(),
        'efficiency_stats': efficiencyStats,
        'tasks': (tasks as List).cast<Map<String, dynamic>>(),
      };
    } catch (e) {
      log('Get daily stats error: $e');
      throw Exception('Failed to get daily stats');
    }
  }
}