// lib/services/subtask_service.dart
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import '../models/subtask_model.dart';
import '../models/user_model.dart';
import '../supabase_client.dart';

class SubtaskService {
  final supabase_flutter.SupabaseClient _supabase = supabase;

  Future<SubtaskModel> createSubtask(SubtaskModel subtask) async {
    try {
      final response = await _supabase
          .from('subtasks')
          .insert(subtask.toJson())
          .select()
          .single();

      return SubtaskModel.fromJson(response);
    } catch (e) {
      log('Create subtask error: $e');
      throw Exception('Failed to create subtask');
    }
  }

  Future<List<SubtaskModel>> getSubtasksByTask(String taskId) async {
    try {
      final response = await _supabase
          .from('subtasks')
          .select()
          .eq('task_id', taskId)
          .order('order_index', ascending: true)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => SubtaskModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Get subtasks error: $e');
      throw Exception('Failed to get subtasks');
    }
  }

  Future<List<SubtaskModel>> getSubtasksWithUsers(String taskId) async {
    try {
      final response = await _supabase
          .from('subtasks')
          .select('''
            *,
            assigned_user:users!assigned_to(*)
          ''')
          .eq('task_id', taskId)
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) {
            final subtask = SubtaskModel.fromJson(json);
            if (json['assigned_user'] != null) {
              final assignedUser = UserModel.fromJson(json['assigned_user']);
              return SubtaskModel(
                id: subtask.id,
                taskId: subtask.taskId,
                title: subtask.title,
                description: subtask.description,
                status: subtask.status,
                priority: subtask.priority,
                assignedTo: subtask.assignedTo,
                orderIndex: subtask.orderIndex,
                createdAt: subtask.createdAt,
                updatedAt: subtask.updatedAt,
                completedAt: subtask.completedAt,
                assignedUser: assignedUser,
              );
            }
            return subtask;
          })
          .toList();
    } catch (e) {
      log('Get subtasks with users error: $e');
      throw Exception('Failed to get subtasks with users');
    }
  }

  Future<SubtaskModel> updateSubtask(
    String subtaskId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('subtasks')
          .update(updates)
          .eq('id', subtaskId)
          .select()
          .single();

      return SubtaskModel.fromJson(response);
    } catch (e) {
      log('Update subtask error: $e');
      throw Exception('Failed to update subtask');
    }
  }

  Future<void> deleteSubtask(String subtaskId) async {
    try {
      await _supabase
          .from('subtasks')
          .delete()
          .eq('id', subtaskId);
    } catch (e) {
      log('Delete subtask error: $e');
      throw Exception('Failed to delete subtask');
    }
  }

  Future<void> updateSubtasksOrder(List<SubtaskModel> subtasks) async {
    try {
      for (int i = 0; i < subtasks.length; i++) {
        await _supabase
            .from('subtasks')
            .update({
              'order_index': i,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', subtasks[i].id);
      }
    } catch (e) {
      log('Update subtasks order error: $e');
      throw Exception('Failed to update subtasks order');
    }
  }

  Future<SubtaskModel> completeSubtask(String subtaskId) async {
    try {
      final updates = {
        'status': 'done',
        'completed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('subtasks')
          .update(updates)
          .eq('id', subtaskId)
          .select()
          .single();

      return SubtaskModel.fromJson(response);
    } catch (e) {
      log('Complete subtask error: $e');
      throw Exception('Failed to complete subtask');
    }
  }
}