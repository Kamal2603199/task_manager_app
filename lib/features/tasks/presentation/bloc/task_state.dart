import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

enum TaskSyncIndicator { idle, syncing, synced, offline, error }

class TaskState extends Equatable {
  final List<Task> tasks;
  final bool isLoading;
  final TaskSyncIndicator syncIndicator;
  final String? errorMessage;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.syncIndicator = TaskSyncIndicator.idle,
    this.errorMessage,
  });

  List<Task> get pendingTasks =>
      tasks.where((t) => t.syncStatus != SyncStatus.synced).toList();
  List<Task> get activeTasks => tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => tasks.where((t) => t.isCompleted).toList();

  TaskState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    TaskSyncIndicator? syncIndicator,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      syncIndicator: syncIndicator ?? this.syncIndicator,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [tasks, isLoading, syncIndicator, errorMessage];
}