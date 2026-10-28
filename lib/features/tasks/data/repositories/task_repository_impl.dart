import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // ---------------- READ ----------------

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      final tasks = await localDataSource.getTasks();
      final visible =
      List<Task>.from(tasks.where((t) => t.syncStatus != SyncStatus.pendingDelete));
      return Right(visible);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Stream<List<Task>> watchTasks() {
    return localDataSource.watchTasks().map(
          (tasks) => List<Task>.from(
        tasks.where((t) => t.syncStatus != SyncStatus.pendingDelete),
      ),
    );
  }

  // ---------------- WRITE ----------------

  @override
  Future<Either<Failure, Task>> addTask(Task task) async {
    try {
      final model = TaskModel.fromEntity(task.copyWith(syncStatus: SyncStatus.pendingCreate));
      await localDataSource.cacheTask(model);
      _fireAndForgetSync();
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      final existing = await localDataSource.getTaskById(task.id);
      final status = existing?.syncStatus == SyncStatus.pendingCreate
          ? SyncStatus.pendingCreate
          : SyncStatus.pendingUpdate;
      final model = TaskModel.fromEntity(
        task.copyWith(updatedAt: DateTime.now(), syncStatus: status),
      );
      await localDataSource.cacheTask(model);
      _fireAndForgetSync();
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      final existing = await localDataSource.getTaskById(id);
      if (existing == null) return const Right(null);

      if (existing.syncStatus == SyncStatus.pendingCreate) {
        await localDataSource.deleteTask(id);
      } else {
        final flagged =
        existing.copyWith(syncStatus: SyncStatus.pendingDelete, updatedAt: DateTime.now());
        await localDataSource.cacheTask(flagged);
      }
      _fireAndForgetSync();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Task>> toggleTaskCompletion(String id) async {
    try {
      final existing = await localDataSource.getTaskById(id);
      if (existing == null) return const Left(CacheFailure('Task mila nahi'));
      final status = existing.syncStatus == SyncStatus.pendingCreate
          ? SyncStatus.pendingCreate
          : SyncStatus.pendingUpdate;
      final updated = existing.copyWith(
        isCompleted: !existing.isCompleted,
        updatedAt: DateTime.now(),
        syncStatus: status,
      );
      await localDataSource.cacheTask(updated);
      _fireAndForgetSync();
      return Right(updated);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  void _fireAndForgetSync() {
    networkInfo.isConnected.then((connected) {
      if (connected) syncTasks();
    });
  }

  // ---------------- SYNC ENGINE ----------------

  @override
  Future<Either<Failure, void>> syncTasks() async {
    final connected = await networkInfo.isConnected;
    if (!connected) {
      return const Left(ServerFailure('No Internet, Changes are safe in local'));
    }

    try {
      final pendingTasks = await localDataSource.getPendingSyncTasks();
      for (final task in pendingTasks) {
        try {
          switch (task.syncStatus) {
            case SyncStatus.pendingCreate:
              final created = await remoteDataSource.createTask(task);
              await localDataSource.cacheTask(
                created.copyWith(id: task.id, syncStatus: SyncStatus.synced),
              );
              break;
            case SyncStatus.pendingUpdate:
              final updated = await remoteDataSource.updateTask(task);
              await localDataSource.cacheTask(
                updated.copyWith(id: task.id, syncStatus: SyncStatus.synced),
              );
              break;
            case SyncStatus.pendingDelete:
              await remoteDataSource.deleteTask(task.id);
              await localDataSource.deleteTask(task.id); // ab hard delete safe hai
              break;
            case SyncStatus.synced:
              break;
          }
        } on ServerException {
          continue;
        }
      }


      try {
        final remoteTasks = await remoteDataSource.getTasks();
        await _mergeRemoteTasks(remoteTasks);
      } on ServerException {
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Sync fail: $e'));
    }
  }


  Future<void> _mergeRemoteTasks(List<TaskModel> remoteTasks) async {
    final localTasks = await localDataSource.getTasks();
    final localMap = {for (final t in localTasks) t.id: t};

    for (final remote in remoteTasks) {
      final local = localMap[remote.id];
      if (local == null) {
        await localDataSource.cacheTask(remote.copyWith(syncStatus: SyncStatus.synced));
      } else if (local.syncStatus == SyncStatus.synced &&
          remote.updatedAt.isAfter(local.updatedAt)) {
        await localDataSource.cacheTask(remote.copyWith(syncStatus: SyncStatus.synced));
      }
    }
  }
}