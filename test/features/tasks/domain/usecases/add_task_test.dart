import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager_app/features/tasks/domain/entities/task.dart';
import 'package:task_manager_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_manager_app/features/tasks/domain/usecases/add_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class FakeTask extends Fake implements Task {}

void main() {
  late AddTask usecase;
  late MockTaskRepository mockRepository;

  setUpAll(() => registerFallbackValue(FakeTask()));

  setUp(() {
    mockRepository = MockTaskRepository();
    usecase = AddTask(mockRepository);
  });

  group('AddTask usecase', () {
    test('title', () async {
      final result = await usecase(const AddTaskParams(title: '   ', description: 'desc'));

      expect(result, isA<Left>());
      verifyZeroInteractions(mockRepository);
    });

    test('valid params', () async {
      final tTask = Task(
        id: 'any-id',
        title: 'Buy milk',
        description: 'desc',
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      when(() => mockRepository.addTask(any())).thenAnswer((_) async => Right(tTask));

      final result = await usecase(const AddTaskParams(title: 'Buy milk', description: 'desc'));

      final captured = verify(() => mockRepository.addTask(captureAny())).captured.single as Task;
      expect(captured.title, 'Buy milk');
      expect(captured.description, 'desc');
      expect(captured.syncStatus, SyncStatus.pendingCreate);
      expect(result, Right(tTask));
    });
  });
}