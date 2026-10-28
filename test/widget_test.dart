import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
import 'package:task_manager_app/features/tasks/presentation/pages/task_list_page.dart';

class MockWatchTasks extends Mock implements WatchTasks {}

class MockAddTask extends Mock implements AddTask {}

class MockUpdateTask extends Mock implements UpdateTask {}

class MockDeleteTask extends Mock implements DeleteTask {}

class MockToggleTaskCompletion extends Mock
    implements ToggleTaskCompletion {}

class MockSyncTasks extends Mock implements SyncTasks {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  testWidgets('Empty tasks screen', (
      WidgetTester tester,
      ) async {
    final watchTasks = MockWatchTasks();
    final networkInfo = MockNetworkInfo();

    // BLoC constructor connectivity stream
    when(
          () => networkInfo.onConnectivityChanged,
    ).thenAnswer((_) => const Stream<bool>.empty());

    // Offline
    when(() => networkInfo.isConnected).thenAnswer((_) async => false);

    // Hive
    when(
          () => watchTasks(),
    ).thenAnswer((_) => Stream<List<Task>>.value(const <Task>[]));

    final bloc = TaskBloc(
      watchTasks: watchTasks,
      addTask: MockAddTask(),
      updateTask: MockUpdateTask(),
      deleteTask: MockDeleteTask(),
      toggleTaskCompletion: MockToggleTaskCompletion(),
      syncTasks: MockSyncTasks(),
      networkInfo: networkInfo,
    );

    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider<TaskBloc>.value(
        value: bloc,
        child: const MaterialApp(
          home: TaskListPage(),
        ),
      ),
    );

    bloc.add(WatchTasksStarted());
    await tester.pumpAndSettle();

    // Empty state
    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('There is no task'), findsOneWidget);

    // New Task button
    await tester.tap(find.text('New Task'));
    await tester.pumpAndSettle();

    expect(find.text('Naya Task'), findsOneWidget);
    expect(find.text('Create Task'), findsOneWidget);

    // Validation message
    await tester.tap(find.text('Create Task'));
    await tester.pumpAndSettle();

    expect(find.text('Title required'), findsOneWidget);
  });
}