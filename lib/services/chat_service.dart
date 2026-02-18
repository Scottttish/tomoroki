// lib/services/chat_service.dart
import 'dart:async';
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import '../models/chat_models.dart';
import '../supabase_client.dart';

class ChatService {
  final supabase_flutter.SupabaseClient _supabase = supabase;

  // Get all chats for a user with last message and participants
  Future<List<ChatModel>> getUserChats(String userId) async {
    try {
      // Get chats where user is a participant
      final participantData = await _supabase
          .from('chat_participants')
          .select('chat_id')
          .eq('user_id', userId);

      if (participantData.isEmpty) return [];

      final chatIds = (participantData as List)
          .map((p) => p['chat_id'].toString())
          .toList();

      final chatsData = await _supabase
          .from('chats')
          .select()
          .inFilter('id', chatIds)
          .order('updated_at', ascending: false);

      List<ChatModel> chats = [];
      for (final chatJson in chatsData) {
        final chat = ChatModel.fromJson(chatJson);

        // Get participants
        final participantsData = await _supabase
            .from('chat_participants')
            .select('''
              *,
              users:user_id(id, username, full_name, avatar_url)
            ''')
            .eq('chat_id', chat.id);

        final participants = (participantsData as List)
            .map((p) => ChatParticipant.fromJson(p))
            .toList();

        // Get last message
        final messagesData = await _supabase
            .from('messages')
            .select('''
              *,
              users:sender_id(id, username, full_name, avatar_url)
            ''')
            .eq('chat_id', chat.id)
            .order('created_at', ascending: false)
            .limit(1);

        MessageModel? lastMessage;
        if (messagesData.isNotEmpty) {
          lastMessage = MessageModel.fromJson(messagesData[0]);
        }

        // Count unread
        final participantEntry = participantsData
            .where((p) => p['user_id'] == userId)
            .toList();
        
        int unreadCount = 0;
        if (participantEntry.isNotEmpty) {
          final lastReadAt = participantEntry[0]['last_read_at'];
          if (lastReadAt != null) {
            final unreadData = await _supabase
                .from('messages')
                .select('id')
                .eq('chat_id', chat.id)
                .neq('sender_id', userId)
                .gt('created_at', lastReadAt);
            unreadCount = (unreadData as List).length;
          } else {
            final unreadData = await _supabase
                .from('messages')
                .select('id')
                .eq('chat_id', chat.id)
                .neq('sender_id', userId);
            unreadCount = (unreadData as List).length;
          }
        }

        chats.add(ChatModel(
          id: chat.id,
          name: chat.name,
          type: chat.type,
          teamId: chat.teamId,
          createdBy: chat.createdBy,
          photoUrl: chat.photoUrl,
          createdAt: chat.createdAt,
          updatedAt: chat.updatedAt,
          participants: participants,
          lastMessage: lastMessage,
          unreadCount: unreadCount,
        ));
      }

      return chats;
    } catch (e) {
      log('Get user chats error: $e');
      return [];
    }
  }

  // Get messages for a chat (paginated)
  Future<List<MessageModel>> getMessages(String chatId, {int limit = 50, int offset = 0}) async {
    try {
      final data = await _supabase
          .from('messages')
          .select('''
            *,
            sender:sender_id(id, username, full_name, avatar_url)
          ''')
          .eq('chat_id', chatId)
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);

      return (data as List).map((json) {
        // Map 'sender' field for fromJson
        if (json['sender'] != null) {
          json['users'] = json['sender'];
        }
        return MessageModel.fromJson(json);
      }).toList();
    } catch (e) {
      log('Get messages error: $e');
      return [];
    }
  }

  // Send a message
  Future<MessageModel?> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? fileUrl,
    String? fileName,
    String? replyToId,
  }) async {
    try {
      String typeStr = 'text';
      switch (type) {
        case MessageType.image: typeStr = 'image'; break;
        case MessageType.file: typeStr = 'file'; break;
        case MessageType.voice: typeStr = 'voice'; break;
        case MessageType.system: typeStr = 'system'; break;
        default: typeStr = 'text';
      }

      final data = await _supabase
          .from('messages')
          .insert({
            'chat_id': chatId,
            'sender_id': senderId,
            'content': content,
            'type': typeStr,
            'file_url': fileUrl,
            'file_name': fileName,
            'reply_to_id': replyToId,
          })
          .select()
          .single();

      // Update chat's updated_at
      await _supabase
          .from('chats')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', chatId);

      return MessageModel.fromJson(data);
    } catch (e) {
      log('Send message error: $e');
      return null;
    }
  }

  // Create a private chat between two users
  Future<ChatModel?> createPrivateChat(String userId, String otherUserId) async {
    try {
      // Check if private chat already exists
      final existingParticipants = await _supabase
          .from('chat_participants')
          .select('chat_id')
          .eq('user_id', userId);

      for (final p in existingParticipants) {
        final chatId = p['chat_id'];
        final chatData = await _supabase
            .from('chats')
            .select()
            .eq('id', chatId)
            .eq('type', 'private')
            .maybeSingle();

        if (chatData != null) {
          final otherParticipant = await _supabase
              .from('chat_participants')
              .select()
              .eq('chat_id', chatId)
              .eq('user_id', otherUserId)
              .maybeSingle();

          if (otherParticipant != null) {
            return ChatModel.fromJson(chatData);
          }
        }
      }

      // Create new chat
      final chatData = await _supabase
          .from('chats')
          .insert({
            'type': 'private',
            'created_by': userId,
          })
          .select()
          .single();

      // Add both participants
      await _supabase.from('chat_participants').insert([
        {'chat_id': chatData['id'], 'user_id': userId},
        {'chat_id': chatData['id'], 'user_id': otherUserId},
      ]);

      return ChatModel.fromJson(chatData);
    } catch (e) {
      log('Create private chat error: $e');
      return null;
    }
  }

  // Create a group chat (for a team)
  Future<ChatModel?> createGroupChat({
    required String name,
    required String createdBy,
    required List<String> memberIds,
    String? teamId,
  }) async {
    try {
      final chatData = await _supabase
          .from('chats')
          .insert({
            'name': name,
            'type': 'group',
            'team_id': teamId,
            'created_by': createdBy,
          })
          .select()
          .single();

      // Add all members as participants
      final participants = memberIds.map((id) => {
        'chat_id': chatData['id'],
        'user_id': id,
      }).toList();

      if (!memberIds.contains(createdBy)) {
        participants.add({
          'chat_id': chatData['id'],
          'user_id': createdBy,
        });
      }

      await _supabase.from('chat_participants').insert(participants);

      return ChatModel.fromJson(chatData);
    } catch (e) {
      log('Create group chat error: $e');
      return null;
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String chatId, String userId) async {
    try {
      await _supabase
          .from('chat_participants')
          .update({'last_read_at': DateTime.now().toIso8601String()})
          .eq('chat_id', chatId)
          .eq('user_id', userId);
    } catch (e) {
      log('Mark as read error: $e');
    }
  }

  // Subscribe to new messages in a chat (Realtime)
  StreamSubscription<List<Map<String, dynamic>>> subscribeToMessages(
    String chatId,
    void Function(MessageModel message) onMessage,
  ) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at')
        .listen((data) {
          if (data.isNotEmpty) {
            final msg = MessageModel.fromJson(data.last);
            onMessage(msg);
          }
        });
  }

  // Search users for new chat
  Future<List<Map<String, dynamic>>> searchUsers(String query, String currentUserId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .neq('id', currentUserId)
          .or('username.ilike.%$query%,full_name.ilike.%$query%,email.ilike.%$query%')
          .limit(20);

      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      log('Search users error: $e');
      return [];
    }
  }
}
