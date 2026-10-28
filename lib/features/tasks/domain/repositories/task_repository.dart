import 'package:dartz/dartz.dart' hide Task;

import '../../../../core/error/failures.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasks();

  Stream<List<Task>> watchTasks();

  Future<Either<Failure, Task>> addTask(Task task);

  Future<Either<Failure, Task>> updateTask(Task task);

  Future<Either<Failure, void>> deleteTask(String id);

  Future<Either<Failure, Task>> toggleTaskCompletion(String id);

  Future<Either<Failure, void>> syncTasks();
}