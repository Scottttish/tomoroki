// lib/models/task_model.dart
import 'package:flutter/material.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String userId;
  final String? teamId;
  final String status;
  final String priority;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? estimatedDuration;
  final int? actualDuration;
  final Color color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final List<String> visibleTo; // user IDs who can see this task

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.userId,
    this.teamId,
    this.status = 'todo',
    this.priority = 'medium',
    this.startTime,
    this.endTime,
    this.estimatedDuration,
    this.actualDuration,
    this.color = const Color(0xFF5D7CF9),
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.visibleTo = const [],
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      userId: json['user_id'] ?? '',
      teamId: json['team_id'],
      status: json['status'] ?? 'todo',
      priority: json['priority'] ?? 'medium',
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      estimatedDuration: json['estimated_duration'],
      actualDuration: json['actual_duration'],
      color: _parseColor(json['color']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }

  static Color _parseColor(dynamic colorValue) {
    if (colorValue == null) return const Color(0xFF5D7CF9);
    if (colorValue is String && colorValue.startsWith('#')) {
      try {
        return Color(int.parse(colorValue.substring(1), radix: 16)).withOpacity(1);
      } catch (_) {
        return const Color(0xFF5D7CF9);
      }
    }
    return const Color(0xFF5D7CF9);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'user_id': userId,
      'team_id': teamId,
      'status': status,
      'priority': priority,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'estimated_duration': estimatedDuration,
      'actual_duration': actualDuration,
      'color': '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    String? teamId,
    String? status,
    String? priority,
    DateTime? startTime,
    DateTime? endTime,
    int? estimatedDuration,
    int? actualDuration,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    List<String>? visibleTo,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      teamId: teamId ?? this.teamId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      visibleTo: visibleTo ?? this.visibleTo,
    );
  }
}