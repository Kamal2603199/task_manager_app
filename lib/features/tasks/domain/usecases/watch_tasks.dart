import '../entities/task.dart';
import '../repositories/task_repository.dart';

class WatchTasks {
  final TaskRepository repository;
  WatchTasks(this.repository);

  Stream<List<Task>> call() => repository.watchTasks();
}