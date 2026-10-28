import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class AddTaskParams extends Equatable {
  final String title;
  final String description;
  const AddTaskParams({required this.title, required this.description});

  @override
  List<Object?> get props => [title, description];
}

class AddTask implements UseCase<Task, AddTaskParams> {
  final TaskRepository repository;
  AddTask(this.repository);

  @override
  Future<Either<Failure, Task>> call(AddTaskParams params) async {
    if (params.title.trim().isEmpty) {
      return const Left(ValidationFailure('Title cannot be empty'));
    }
    final now = DateTime.now();
    final task = Task(
      id: const Uuid().v4(),
      title: params.title.trim(),
      description: params.description.trim(),
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pendingCreate,
    );
    return repository.addTask(task);
  }
}