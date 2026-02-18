// lib/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? telegramUsername;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.telegramUsername,
    this.role = 'user',
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.isActive = true,
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      telegramUsername: json['telegram_username'],
      role: json['role'] ?? 'user',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'telegram_username': telegramUsername,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
    };
  }
}