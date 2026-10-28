import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}


class WatchTasksStarted extends TaskEvent {}

class TasksUpdated extends TaskEvent {
  final List<Task> tasks;
  const TasksUpdated(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class AddTaskRequested extends TaskEvent {
  final String title;
  final String description;
  const AddTaskRequested({required this.title, required this.description});
  @override
  List<Object?> get props => [title, description];
}

class UpdateTaskRequested extends TaskEvent {
  final Task task;
  const UpdateTaskRequested(this.task);
  @override
  List<Object?> get props => [task];
}

class DeleteTaskRequested extends TaskEvent {
  final String id;
  const DeleteTaskRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ToggleTaskRequested extends TaskEvent {
  final String id;
  const ToggleTaskRequested(this.id);
  @override
  List<Object?> get props => [id];
}


class SyncRequested extends TaskEvent {}

class ConnectivityStatusChanged extends TaskEvent {
  final bool isConnected;
  const ConnectivityStatusChanged(this.isConnected);
  @override
  List<Object?> get props => [isConnected];
}