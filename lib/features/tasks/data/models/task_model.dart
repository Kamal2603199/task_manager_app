import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.isCompleted,
    required super.createdAt,
    required super.updatedAt,
    required super.syncStatus,
  });

  factory TaskModel.fromEntity(Task task) => TaskModel(
    id: task.id,
    title: task.title,
    description: task.description,
    isCompleted: task.isCompleted,
    createdAt: task.createdAt,
    updatedAt: task.updatedAt,
    syncStatus: task.syncStatus,
  );

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'].toString(),
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    isCompleted: json['isCompleted'] == true,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    syncStatus: SyncStatus.synced,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}