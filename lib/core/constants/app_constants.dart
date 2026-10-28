class AppConstants {
  AppConstants._();

  static const String taskBoxName = 'tasks_box_v1';
  static const String apiBaseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration requestTimeout = Duration(seconds: 10);
  static const Duration periodicSyncInterval = Duration(minutes: 2);
}