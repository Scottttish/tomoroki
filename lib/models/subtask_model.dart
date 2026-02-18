// lib/models/subtask_model.dart
import 'user_model.dart';

class SubtaskModel {
  final String id;
  final String taskId;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String? assignedTo;
  final String? completedBy;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final UserModel? assignedUser;
  final UserModel? completedByUser;

  SubtaskModel({
    required this.id,
    required this.taskId,
    required this.title,
    this.description,
    this.status = 'todo',
    this.priority = 'medium',
    this.assignedTo,
    this.completedBy,
    this.orderIndex = 0,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.assignedUser,
    this.completedByUser,
  });

  bool get isCompleted => status == 'done';

  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    UserModel? assignedUser;
    if (json['assigned_user'] != null && json['assigned_user'] is Map) {
      try {
        assignedUser = UserModel.fromJson(json['assigned_user']);
      } catch (_) {}
    }

    UserModel? completedByUser;
    if (json['completed_by_user'] != null && json['completed_by_user'] is Map) {
      try {
        completedByUser = UserModel.fromJson(json['completed_by_user']);
      } catch (_) {}
    }

    return SubtaskModel(
      id: json['id']?.toString() ?? '',
      taskId: json['task_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'todo',
      priority: json['priority'] ?? 'medium',
      assignedTo: json['assigned_to'],
      completedBy: json['completed_by'],
      orderIndex: json['order_index'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      assignedUser: assignedUser,
      completedByUser: completedByUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'assigned_to': assignedTo,
      'completed_by': completedBy,
      'order_index': orderIndex,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  SubtaskModel copyWith({
    String? id,
    String? taskId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assignedTo,
    String? completedBy,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    UserModel? assignedUser,
    UserModel? completedByUser,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      completedBy: completedBy ?? this.completedBy,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      assignedUser: assignedUser ?? this.assignedUser,
      completedByUser: completedByUser ?? this.completedByUser,
    );
  }
}