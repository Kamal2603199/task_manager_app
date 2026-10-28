import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/empty_tasks_view.dart';
import '../widgets/sync_status_indicator.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_page.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF0891F4),
        foregroundColor: Colors.white,
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) => SyncStatusIndicator(
              status: state.syncIndicator,
              pendingCount: state.pendingTasks.length,
              iconColor: Colors.white,
            ),
          ),
        ],
      ),

      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.tasks.isEmpty) {
            return const EmptyTasksView();
          }

          final active = state.activeTasks;
          final completed = state.completedTasks;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TaskBloc>().add(SyncRequested());
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              children: [
                if (active.isNotEmpty)
                  _SectionHeader(title: 'Pending (${active.length})'),
                ...active.map((task) => TaskCard(task: task)),

                if (completed.isNotEmpty)
                  _SectionHeader(title: 'Completed (${completed.length})'),
                ...completed.map((task) => TaskCard(task: task)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditTaskPage(),
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0891F4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'New Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 14, 6, 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.outline,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}