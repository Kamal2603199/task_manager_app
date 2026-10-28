import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTask implements UseCase<Task, Task> {
  final TaskRepository repository;
  UpdateTask(this.repository);

  @override
  Future<Either<Failure, Task>> call(Task params) {
    if (params.title.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Title cannot be empty')));
    }
    return repository.updateTask(params);
  }
}