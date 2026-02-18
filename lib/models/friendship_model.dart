// lib/models/friendship_model.dart
import 'user_model.dart';

class FriendshipModel {
  final String id;
  final String userId;
  final String friendId;
  final String status; // pending, accepted, declined
  final DateTime createdAt;
  // Joined
  final UserModel? friend;

  FriendshipModel({
    required this.id,
    required this.userId,
    required this.friendId,
    this.status = 'pending',
    required this.createdAt,
    this.friend,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';

  factory FriendshipModel.fromJson(Map<String, dynamic> json) {
    UserModel? friend;
    if (json['friend'] != null && json['friend'] is Map) {
      friend = UserModel.fromJson(json['friend']);
    }

    return FriendshipModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      friendId: json['friend_id']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      friend: friend,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'friend_id': friendId,
      'status': status,
    };
  }
}
