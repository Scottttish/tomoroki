// lib/services/task_service.dart
import 'dart:developer';
import '../models/task_model.dart';
import '../supabase_client.dart';

class TaskService {
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await supabase
          .from('tasks')
          .insert(task.toJson())
          .select()
          .single();

      return TaskModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('Create task error: $e');
      throw Exception('Failed to create task');
    }
  }

  Future<List<TaskModel>> getTasksByUser(String userId, {String? status}) async {
    try {
      final query = supabase
          .from('tasks')
          .select()
          .eq('user_id', userId);

      if (status != null) {
        query.eq('status', status);
      }

      query.order('created_at', ascending: false);

      final response = await query;

      return (response as List)
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Get tasks error: $e');
      throw Exception('Failed to get tasks');
    }
  }

  Future<List<TaskModel>> getTasksByTeam(String teamId, {String? status}) async {
    try {
      final query = supabase
          .from('tasks')
          .select()
          .eq('team_id', teamId);

      if (status != null) {
        query.eq('status', status);
      }

      query.order('created_at', ascending: false);

      final response = await query;

      return (response as List)
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Get team tasks error: $e');
      throw Exception('Failed to get team tasks');
    }
  }

  Future<TaskModel> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabase
          .from('tasks')
          .update(updates)
          .eq('id', taskId)
          .select()
          .single();

      return TaskModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('Update task error: $e');
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await supabase
          .from('tasks')
          .delete()
          .eq('id', taskId);
    } catch (e) {
      log('Delete task error: $e');
      throw Exception('Failed to delete task');
    }
  }

  Future<TaskModel> getTaskById(String taskId) async {
    try {
      final response = await supabase
          .from('tasks')
          .select()
          .eq('id', taskId)
          .single();

      return TaskModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('Get task error: $e');
      throw Exception('Failed to get task');
    }
  }

  Future<TaskModel> completeTask(String taskId) async {
    try {
      final updates = {
        'status': 'done',
        'completed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('tasks')
          .update(updates)
          .eq('id', taskId)
          .select()
          .single();

      return TaskModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('Complete task error: $e');
      throw Exception('Failed to complete task');
    }
  }

  Future<TaskModel> updateTaskTime({
    required String taskId,
    required int actualDuration,
  }) async {
    try {
      final updates = {
        'actual_duration': actualDuration,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('tasks')
          .update(updates)
          .eq('id', taskId)
          .select()
          .single();

      return TaskModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('Update task time error: $e');
      throw Exception('Failed to update task time');
    }
  }
}