import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/sync_tasks.dart';
import '../../domain/usecases/toggle_task_completion.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/watch_tasks.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final WatchTasks watchTasks;
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  final ToggleTaskCompletion toggleTaskCompletion;
  final SyncTasks syncTasks;
  final NetworkInfo networkInfo;

  StreamSubscription? _taskStreamSub;
  StreamSubscription? _connectivitySub;
  Timer? _periodicSyncTimer;

  TaskBloc({
    required this.watchTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
    required this.toggleTaskCompletion,
    required this.syncTasks,
    required this.networkInfo,
  }) : super(const TaskState()) {
    on<WatchTasksStarted>(_onWatchTasksStarted);
    on<TasksUpdated>(_onTasksUpdated);
    on<AddTaskRequested>(_onAddTaskRequested);
    on<UpdateTaskRequested>(_onUpdateTaskRequested);
    on<DeleteTaskRequested>(_onDeleteTaskRequested);
    on<ToggleTaskRequested>(_onToggleTaskRequested);
    on<SyncRequested>(_onSyncRequested);
    on<ConnectivityStatusChanged>(_onConnectivityStatusChanged);

    _connectivitySub = networkInfo.onConnectivityChanged.listen((isConnected) {
      add(ConnectivityStatusChanged(isConnected));
    });

    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      add(SyncRequested());
    });
  }

  Future<void> _onWatchTasksStarted(WatchTasksStarted event, Emitter<TaskState> emit) async {
    emit(state.copyWith(isLoading: true));
    await _taskStreamSub?.cancel();
    _taskStreamSub = watchTasks().listen((tasks) => add(TasksUpdated(tasks)));
    add(SyncRequested());
  }

  void _onTasksUpdated(TasksUpdated event, Emitter<TaskState> emit) {
    final sorted = List.of(event.tasks)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    emit(state.copyWith(isLoading: false, tasks: sorted, clearError: true));
  }

  Future<void> _onAddTaskRequested(AddTaskRequested event, Emitter<TaskState> emit) async {
    final result = await addTask(AddTaskParams(title: event.title, description: event.description));
    result.fold(
          (failure) => emit(state.copyWith(errorMessage: failure.message)),
          (_) {},
    );
  }

  Future<void> _onUpdateTaskRequested(UpdateTaskRequested event, Emitter<TaskState> emit) async {
    final result = await updateTask(event.task);
    result.fold((failure) => emit(state.copyWith(errorMessage: failure.message)), (_) {});
  }

  Future<void> _onDeleteTaskRequested(DeleteTaskRequested event, Emitter<TaskState> emit) async {
    final result = await deleteTask(event.id);
    result.fold((failure) => emit(state.copyWith(errorMessage: failure.message)), (_) {});
  }

  Future<void> _onToggleTaskRequested(ToggleTaskRequested event, Emitter<TaskState> emit) async {
    final result = await toggleTaskCompletion(event.id);
    result.fold((failure) => emit(state.copyWith(errorMessage: failure.message)), (_) {});
  }

  Future<void> _onSyncRequested(SyncRequested event, Emitter<TaskState> emit) async {
    final connected = await networkInfo.isConnected;
    if (!connected) {
      emit(state.copyWith(syncIndicator: TaskSyncIndicator.offline));
      return;
    }
    emit(state.copyWith(syncIndicator: TaskSyncIndicator.syncing));
    final result = await syncTasks(NoParams());
    result.fold(
          (failure) => emit(state.copyWith(syncIndicator: TaskSyncIndicator.error)),
          (_) => emit(state.copyWith(syncIndicator: TaskSyncIndicator.synced)),
    );
  }

  Future<void> _onConnectivityStatusChanged(
      ConnectivityStatusChanged event, Emitter<TaskState> emit) async {
    if (event.isConnected) {
      add(SyncRequested());
    } else {
      emit(state.copyWith(syncIndicator: TaskSyncIndicator.offline));
    }
  }

  @override
  Future<void> close() {
    _taskStreamSub?.cancel();
    _connectivitySub?.cancel();
    _periodicSyncTimer?.cancel();
    return super.close();
  }
}