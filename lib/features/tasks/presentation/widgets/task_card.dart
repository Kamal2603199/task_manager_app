import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../pages/add_edit_task_page.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => context.read<TaskBloc>().add(DeleteTaskRequested(task.id)),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 0,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditTaskPage(task: task)),
          ),
          leading: GestureDetector(
            onTap: () => context.read<TaskBloc>().add(ToggleTaskRequested(task.id)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted ? theme.colorScheme.primary : Colors.transparent,
                border: Border.all(color: theme.colorScheme.primary, width: 2),
              ),
              child: task.isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
          ),
          title: Text(
            task.title,
            style: theme.textTheme.titleMedium?.copyWith(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? theme.colorScheme.outline : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: task.description.isNotEmpty
              ? Text(task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline))
              : null,
          trailing: Icon(
            task.syncStatus == SyncStatus.synced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
            size: 18,
            color: task.syncStatus == SyncStatus.synced ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Do you want to delete "${task.title}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}