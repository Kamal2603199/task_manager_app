import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/task.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel?> getTaskById(String id);
  Future<void> cacheTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<List<TaskModel>> getPendingSyncTasks();
  Stream<List<TaskModel>> watchTasks();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<TaskModel> taskBox;
  TaskLocalDataSourceImpl(this.taskBox);

  List<TaskModel> _sorted() =>
      taskBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      return _sorted();
    } catch (e) {
      throw CacheException('Local storage se tasks read nahi ho paye');
    }
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    try {
      return taskBox.get(id);
    } catch (e) {
      throw CacheException('Task fetch karne me error aaya');
    }
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    try {
      // key = task.id -> same id dobara save karne par overwrite ho jayega (upsert)
      await taskBox.put(task.id, task);
    } catch (e) {
      throw CacheException('Task local save nahi ho saka');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await taskBox.delete(id);
    } catch (e) {
      throw CacheException('Task local delete nahi ho saka');
    }
  }

  @override
  Future<List<TaskModel>> getPendingSyncTasks() async {
    return taskBox.values.where((t) => t.syncStatus != SyncStatus.synced).toList();
  }

  @override
  Stream<List<TaskModel>> watchTasks() async* {
    // Pehle current snapshot turant bhejo (initial load)
    yield _sorted();
    // Fir Hive box me jo bhi change ho (put/delete), uspe naya snapshot bhejo
    yield* taskBox.watch().map((_) => _sorted());
  }
}