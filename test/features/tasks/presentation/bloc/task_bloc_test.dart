import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager_app/core/error/failures.dart';
import 'package:task_manager_app/core/usecases/usecase.dart';
import 'package:task_manager_app/core/network/network_info.dart';
import 'package:task_manager_app/features/tasks/domain/entities/task.dart';
import 'package:task_manager_app/features/tasks/domain/usecases/add_task.dart';
import 'package:task_manager_app/features/tasks/domain/usecases/delete_task.dart';
import 'package:task_manager_app/features/tasks/domain/usecases/sync_tasks.dart';
import 'package:task_manager_app/features/tasks/domain/usecases/toggle_task_completion.dart';
import 'package:task_manager_app/features/tasks/domain/usecases/update_task.dart';
import 'package:task_manager_app/features/tasks/domain/usecases/watch_tasks.dart';
import 'package:task_manager_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager_app/features/tasks/presentation/bloc/task_event.dart';
import 'package:task_manager_app/features/tasks/presentation/bloc/task_state.dart';

class MockWatchTasks extends Mock implements WatchTasks {}
class MockAddTask extends Mock implements AddTask {}
class MockUpdateTask extends Mock implements UpdateTask {}
class MockDeleteTask extends Mock implements DeleteTask {}
class MockToggleTaskCompletion extends Mock implements ToggleTaskCompletion {}
class MockSyncTasks extends Mock implements SyncTasks {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockWatchTasks mockWatchTasks;
  late MockAddTask mockAddTask;
  late MockUpdateTask mockUpdateTask;
  late MockDeleteTask mockDeleteTask;
  late MockToggleTaskCompletion mockToggleTaskCompletion;
  late MockSyncTasks mockSyncTasks;
  late MockNetworkInfo mockNetworkInfo;
  late TaskBloc bloc;

  final tTask = Task(
    id: '1',
    title: 'Test',
    description: '',
    isCompleted: false,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
    syncStatus: SyncStatus.synced,
  );

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(const AddTaskParams(title: '', description: ''));
  });

  setUp(() {
    mockWatchTasks = MockWatchTasks();
    mockAddTask = MockAddTask();
    mockUpdateTask = MockUpdateTask();
    mockDeleteTask = MockDeleteTask();
    mockToggleTaskCompletion = MockToggleTaskCompletion();
    mockSyncTasks = MockSyncTasks();
    mockNetworkInfo = MockNetworkInfo();

    when(() => mockNetworkInfo.onConnectivityChanged).thenAnswer((_) => const Stream.empty());
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    when(() => mockWatchTasks()).thenAnswer((_) => Stream.value([tTask]));
    when(() => mockSyncTasks(any())).thenAnswer((_) async => const Right(null));

    bloc = TaskBloc(
      watchTasks: mockWatchTasks,
      addTask: mockAddTask,
      updateTask: mockUpdateTask,
      deleteTask: mockDeleteTask,
      toggleTaskCompletion: mockToggleTaskCompletion,
      syncTasks: mockSyncTasks,
      networkInfo: mockNetworkInfo,
    );
  });

  tearDown(() => bloc.close());

  test('initial state should be correct', () {
    expect(bloc.state, const TaskState());
  });

  blocTest<TaskBloc, TaskState>(
    'WatchTasksStarted',
    build: () => bloc,
    act: (b) => b.add(WatchTasksStarted()),
    expect: () => [
      const TaskState(isLoading: true),
      TaskState(isLoading: false, tasks: [tTask]),
      TaskState(isLoading: false, tasks: [tTask], syncIndicator: TaskSyncIndicator.syncing),
      TaskState(isLoading: false, tasks: [tTask], syncIndicator: TaskSyncIndicator.synced),
    ],
  );

  blocTest<TaskBloc, TaskState>(
    'AddTaskRequested should have correct params',
    build: () {
      when(() => mockAddTask(any())).thenAnswer((_) async => Right(tTask));
      return bloc;
    },
    act: (b) => b.add(const AddTaskRequested(title: 'Test', description: '')),
    verify: (_) {
      verify(() => mockAddTask(const AddTaskParams(title: 'Test', description: ''))).called(1);
    },
  );

  blocTest<TaskBloc, TaskState>(
    'deleteTask failed',
    build: () {
      when(() => mockDeleteTask(any())).thenAnswer((_) async => const Left(CacheFailure('Delete failed')));
      return bloc;
    },
    act: (b) => b.add(const DeleteTaskRequested('1')),
    expect: () => [const TaskState(errorMessage: 'Delete failed')],
  );
}