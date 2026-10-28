import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasks implements UseCase<List<Task>, NoParams> {
  final TaskRepository repository;
  GetTasks(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(NoParams params) {
    return repository.getTasks();
  }
}