import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class DeleteTask implements UseCase<void, String> {
  final TaskRepository repository;
  DeleteTask(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteTask(id);
  }
}