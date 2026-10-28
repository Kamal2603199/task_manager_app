import 'package:flutter/material.dart';

class EmptyTasksView extends StatelessWidget {
  const EmptyTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checklist_rtl_rounded, size: 72, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('No available Tasks', style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text('Create tasks by clicking on New Task Button', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}