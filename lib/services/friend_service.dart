// lib/services/friend_service.dart
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import '../models/user_model.dart';
import '../supabase_client.dart';

class FriendService {
  final supabase_flutter.SupabaseClient _supabase = supabase;

  // Get all accepted friends
  Future<List<UserModel>> getFriends(String userId) async {
    try {
      // Friends where I sent the request
      final sentData = await _supabase
          .from('friendships')
          .select('''
            friend:friend_id(*)
          ''')
          .eq('user_id', userId)
          .eq('status', 'accepted');

      // Friends where I received the request
      final receivedData = await _supabase
          .from('friendships')
          .select('''
            friend:user_id(*)
          ''')
          .eq('friend_id', userId)
          .eq('status', 'accepted');

      final List<UserModel> friends = [];

      for (final item in sentData) {
        if (item['friend'] != null) {
          friends.add(UserModel.fromJson(item['friend']));
        }
      }

      for (final item in receivedData) {
        if (item['friend'] != null) {
          final user = UserModel.fromJson(item['friend']);
          if (!friends.any((f) => f.id == user.id)) {
            friends.add(user);
          }
        }
      }

      return friends;
    } catch (e) {
      log('Get friends error: $e');
      return [];
    }
  }

  // Get pending friend requests (received)
  Future<List<Map<String, dynamic>>> getPendingRequests(String userId) async {
    try {
      final data = await _supabase
          .from('friendships')
          .select('''
            *,
            sender:user_id(*)
          ''')
          .eq('friend_id', userId)
          .eq('status', 'pending');

      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      log('Get pending requests error: $e');
      return [];
    }
  }

  // Send friend request
  Future<bool> sendFriendRequest(String userId, String friendId) async {
    try {
      // Check if already friends or request exists
      final existing = await _supabase
          .from('friendships')
          .select()
          .or('and(user_id.eq.$userId,friend_id.eq.$friendId),and(user_id.eq.$friendId,friend_id.eq.$userId)')
          .maybeSingle();

      if (existing != null) {
        return false; // Already exists
      }

      await _supabase.from('friendships').insert({
        'user_id': userId,
        'friend_id': friendId,
        'status': 'pending',
      });

      return true;
    } catch (e) {
      log('Send friend request error: $e');
      return false;
    }
  }

  // Accept friend request
  Future<bool> acceptFriendRequest(String friendshipId) async {
    try {
      await _supabase
          .from('friendships')
          .update({'status': 'accepted'})
          .eq('id', friendshipId);
      return true;
    } catch (e) {
      log('Accept friend request error: $e');
      return false;
    }
  }

  // Decline friend request
  Future<bool> declineFriendRequest(String friendshipId) async {
    try {
      await _supabase
          .from('friendships')
          .update({'status': 'declined'})
          .eq('id', friendshipId);
      return true;
    } catch (e) {
      log('Decline friend request error: $e');
      return false;
    }
  }

  // Remove friend
  Future<bool> removeFriend(String userId, String friendId) async {
    try {
      await _supabase
          .from('friendships')
          .delete()
          .or('and(user_id.eq.$userId,friend_id.eq.$friendId),and(user_id.eq.$friendId,friend_id.eq.$userId)');
      return true;
    } catch (e) {
      log('Remove friend error: $e');
      return false;
    }
  }

  // Check if two users are friends
  Future<bool> areFriends(String userId, String friendId) async {
    try {
      final data = await _supabase
          .from('friendships')
          .select()
          .or('and(user_id.eq.$userId,friend_id.eq.$friendId),and(user_id.eq.$friendId,friend_id.eq.$userId)')
          .eq('status', 'accepted')
          .maybeSingle();

      return data != null;
    } catch (e) {
      log('Check friends error: $e');
      return false;
    }
  }

  // Search users (for adding friends)
  Future<List<UserModel>> searchUsers(String query, String currentUserId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .neq('id', currentUserId)
          .or('username.ilike.%$query%,full_name.ilike.%$query%')
          .limit(20);

      return (data as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Search users error: $e');
      return [];
    }
  }
}
