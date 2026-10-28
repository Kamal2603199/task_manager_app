import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/datasources/task_remote_datasource.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/add_task.dart';
import '../../features/tasks/domain/usecases/delete_task.dart';
import '../../features/tasks/domain/usecases/get_tasks.dart';
import '../../features/tasks/domain/usecases/sync_tasks.dart';
import '../../features/tasks/domain/usecases/toggle_task_completion.dart';
import '../../features/tasks/domain/usecases/update_task.dart';
import '../../features/tasks/domain/usecases/watch_tasks.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';
import '../constants/app_constants.dart';
import '../network/network_info.dart';

final sl = GetIt.instance; // "sl" = Service Locator

Future<void> init() async {
  // -------- Bloc --------
  sl.registerFactory(
        () => TaskBloc(
      watchTasks: sl(),
      addTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
      toggleTaskCompletion: sl(),
      syncTasks: sl(),
      networkInfo: sl(),
    ),
  );

  // -------- UseCases --------
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => WatchTasks(sl()));
  sl.registerLazySingleton(() => AddTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerLazySingleton(() => ToggleTaskCompletion(sl()));
  sl.registerLazySingleton(() => SyncTasks(sl()));

  // -------- Repository --------
  sl.registerLazySingleton<TaskRepository>(
        () => TaskRepositoryImpl(localDataSource: sl(), remoteDataSource: sl(), networkInfo: sl()),
  );

  // -------- DataSources --------
  sl.registerLazySingleton<TaskLocalDataSource>(() => TaskLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<TaskRemoteDataSource>(() => TaskRemoteDataSourceImpl(client: sl()));

  // -------- External (Hive box, http client, connectivity) --------
  final taskBox = await Hive.openBox<TaskModel>(AppConstants.taskBoxName);
  sl.registerLazySingleton<Box<TaskModel>>(() => taskBox);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}