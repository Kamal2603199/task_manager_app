import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class ToggleTaskCompletion implements UseCase<Task, String> {
  final TaskRepository repository;
  ToggleTaskCompletion(this.repository);

  @override
  Future<Either<Failure, Task>> call(String id) {
    return repository.toggleTaskCompletion(id);
  }
}