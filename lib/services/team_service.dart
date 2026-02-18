// lib/services/team_service.dart
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import '../supabase_client.dart';

class TeamService {
  final supabase_flutter.SupabaseClient _supabase = supabase;

  Future<Map<String, dynamic>> createTeam({
    required String name,
    required String ownerId,
    String? description,
    String? color,
    bool isPublic = false,
  }) async {
    try {
      final response = await _supabase
          .from('teams')
          .insert({
            'name': name,
            'description': description,
            'owner_id': ownerId,
            'color': color ?? '#5D7CF9',
            'is_public': isPublic,
          })
          .select()
          .single();

      await _supabase
          .from('team_members')
          .insert({
            'team_id': response['id'],
            'user_id': ownerId,
            'role': 'admin',
            'is_accepted': true,
          });

      return response;
    } catch (e) {
      log('Create team error: $e');
      throw Exception('Failed to create team');
    }
  }

  Future<List<Map<String, dynamic>>> getUserTeams(String userId) async {
    try {
      final response = await _supabase
          .from('team_members')
          .select('''
            team:teams(*),
            role,
            joined_at
          ''')
          .eq('user_id', userId)
          .eq('is_accepted', true);

      return (response as List).map((item) {
        final team = item['team'] as Map<String, dynamic>;
        team['user_role'] = item['role'];
        team['joined_at'] = item['joined_at'];
        return team;
      }).toList();
    } catch (e) {
      log('Get user teams error: $e');
      throw Exception('Failed to get user teams');
    }
  }

  Future<void> inviteToTeam({
    required String teamId,
    required String userId,
    required String invitedBy,
    String role = 'member',
  }) async {
    try {
      await _supabase
          .from('team_members')
          .insert({
            'team_id': teamId,
            'user_id': userId,
            'role': role,
            'invited_by': invitedBy,
            'is_accepted': false,
          });
    } catch (e) {
      log('Invite to team error: $e');
      throw Exception('Failed to invite to team');
    }
  }

  Future<void> acceptInvitation(String teamId, String userId) async {
    try {
      await _supabase
          .from('team_members')
          .update({
            'is_accepted': true,
            'joined_at': DateTime.now().toIso8601String(),
          })
          .eq('team_id', teamId)
          .eq('user_id', userId);
    } catch (e) {
      log('Accept invitation error: $e');
      throw Exception('Failed to accept invitation');
    }
  }

  Future<void> removeFromTeam(String teamId, String userId) async {
    try {
      await _supabase
          .from('team_members')
          .delete()
          .eq('team_id', teamId)
          .eq('user_id', userId);
    } catch (e) {
      log('Remove from team error: $e');
      throw Exception('Failed to remove from team');
    }
  }

  Future<List<Map<String, dynamic>>> getTeamMembers(String teamId) async {
    try {
      final response = await _supabase
          .from('team_members')
          .select('''
            user:users(*),
            role,
            joined_at,
            is_accepted
          ''')
          .eq('team_id', teamId);

      return (response as List).map((item) {
        final user = item['user'] as Map<String, dynamic>;
        user['team_role'] = item['role'];
        user['joined_at'] = item['joined_at'];
        user['is_accepted'] = item['is_accepted'];
        return user;
      }).toList();
    } catch (e) {
      log('Get team members error: $e');
      throw Exception('Failed to get team members');
    }
  }
}