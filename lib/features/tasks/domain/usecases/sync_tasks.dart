import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class SyncTasks implements UseCase<void, NoParams> {
  final TaskRepository repository;
  SyncTasks(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.syncTasks();
  }
}