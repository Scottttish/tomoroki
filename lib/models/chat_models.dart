// lib/models/chat_models.dart
import 'package:flutter/material.dart';

enum ChatType { private, group }
enum MessageType { text, image, file, voice, system }

class ChatModel {
  final String id;
  final String? name;
  final ChatType type;
  final String? teamId;
  final String? createdBy;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Joined fields — not stored in chats table
  final List<ChatParticipant> participants;
  final MessageModel? lastMessage;
  final int unreadCount;

  ChatModel({
    required this.id,
    this.name,
    this.type = ChatType.private,
    this.teamId,
    this.createdBy,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.participants = const [],
    this.lastMessage,
    this.unreadCount = 0,
  });

  String displayName(String currentUserId) {
    if (name != null && name!.isNotEmpty) return name!;
    // For private chats, show the other person's name
    final other = participants.where((p) => p.userId != currentUserId).toList();
    if (other.isNotEmpty && other.first.user != null) {
      return other.first.user!.displayName;
    }
    return 'Чат';
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id']?.toString() ?? '',
      name: json['name'],
      type: json['type'] == 'group' ? ChatType.group : ChatType.private,
      teamId: json['team_id'],
      createdBy: json['created_by'],
      photoUrl: json['photo_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type == ChatType.group ? 'group' : 'private',
      'team_id': teamId,
      'created_by': createdBy,
      'photo_url': photoUrl,
    };
  }
}

class ChatParticipant {
  final String id;
  final String chatId;
  final String userId;
  final DateTime joinedAt;
  final DateTime? lastReadAt;
  // Joined
  final ChatUserModel? user;

  ChatParticipant({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.joinedAt,
    this.lastReadAt,
    this.user,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    ChatUserModel? user;
    if (json['user'] != null && json['user'] is Map) {
      user = ChatUserModel.fromJson(json['user']);
    } else if (json['users'] != null && json['users'] is Map) {
      user = ChatUserModel.fromJson(json['users']);
    }

    return ChatParticipant(
      id: json['id']?.toString() ?? '',
      chatId: json['chat_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      joinedAt: json['joined_at'] != null ? DateTime.parse(json['joined_at']) : DateTime.now(),
      lastReadAt: json['last_read_at'] != null ? DateTime.parse(json['last_read_at']) : null,
      user: user,
    );
  }
}

class ChatUserModel {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final bool isOnline;

  ChatUserModel({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.isOnline = false,
  });

  String get displayName => fullName ?? username;

  String get initials {
    final name = displayName;
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final String? fileUrl;
  final String? fileName;
  final String? replyToId;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Joined
  final ChatUserModel? sender;
  final MessageModel? replyTo;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.fileUrl,
    this.fileName,
    this.replyToId,
    this.isEdited = false,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.replyTo,
  });

  String get timeFormatted {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (messageDay == today) {
      return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Вчера';
    } else if (now.difference(createdAt).inDays < 7) {
      final days = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];
      return days[createdAt.weekday % 7];
    } else {
      return '${createdAt.day}.${createdAt.month}.${createdAt.year.toString().substring(2)}';
    }
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    ChatUserModel? sender;
    if (json['sender'] != null && json['sender'] is Map) {
      sender = ChatUserModel.fromJson(json['sender']);
    } else if (json['users'] != null && json['users'] is Map) {
      sender = ChatUserModel.fromJson(json['users']);
    }

    MessageType msgType = MessageType.text;
    switch (json['type']) {
      case 'image': msgType = MessageType.image; break;
      case 'file': msgType = MessageType.file; break;
      case 'voice': msgType = MessageType.voice; break;
      case 'system': msgType = MessageType.system; break;
    }

    return MessageModel(
      id: json['id']?.toString() ?? '',
      chatId: json['chat_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      content: json['content'] ?? '',
      type: msgType,
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      replyToId: json['reply_to_id'],
      isEdited: json['is_edited'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      sender: sender,
    );
  }

  Map<String, dynamic> toJson() {
    String typeStr = 'text';
    switch (type) {
      case MessageType.image: typeStr = 'image'; break;
      case MessageType.file: typeStr = 'file'; break;
      case MessageType.voice: typeStr = 'voice'; break;
      case MessageType.system: typeStr = 'system'; break;
      default: typeStr = 'text';
    }

    return {
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'type': typeStr,
      'file_url': fileUrl,
      'file_name': fileName,
      'reply_to_id': replyToId,
      'is_edited': isEdited,
    };
  }
}