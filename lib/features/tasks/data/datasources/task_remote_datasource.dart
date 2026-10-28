import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final http.Client client;
  TaskRemoteDataSourceImpl({required this.client});

  Uri _uri(String path) => Uri.parse('${AppConstants.apiBaseUrl}$path');

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final response =
      await client.get(_uri('/tasks')).timeout(AppConstants.requestTimeout);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body) as List;
        return data.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ServerException('Tasks fetch fail: ${response.statusCode}');
    } on TimeoutException {
      throw ServerException('Request timeout ho gaya');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await client
          .post(_uri('/tasks'),
          headers: {'Content-Type': 'application/json'}, body: json.encode(task.toJson()))
          .timeout(AppConstants.requestTimeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskModel.fromJson(json.decode(response.body));
      }
      throw ServerException('Task create fail: ${response.statusCode}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await client
          .put(_uri('/tasks/${task.id}'),
          headers: {'Content-Type': 'application/json'}, body: json.encode(task.toJson()))
          .timeout(AppConstants.requestTimeout);
      if (response.statusCode == 200) {
        return TaskModel.fromJson(json.decode(response.body));
      }
      throw ServerException('Task update fail: ${response.statusCode}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final response =
      await client.delete(_uri('/tasks/$id')).timeout(AppConstants.requestTimeout);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Task delete fail: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}