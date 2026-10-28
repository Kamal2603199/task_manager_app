import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class SyncStatusIndicator extends StatelessWidget {
  final TaskSyncIndicator status;
  final int pendingCount;
  final Color? iconColor;

  const SyncStatusIndicator({
    super.key,
    required this.status,
    required this.pendingCount,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    late IconData icon;
    late Color statusColor;
    late String tooltip;

    switch (status) {
      case TaskSyncIndicator.syncing:
        icon = Icons.sync;
        statusColor = Colors.blue;
        tooltip = 'Syncing';
        break;

      case TaskSyncIndicator.offline:
        icon = Icons.cloud_off;
        statusColor = Colors.grey;
        tooltip = 'Offline';
        break;

      case TaskSyncIndicator.error:
        icon = Icons.sync_problem;
        statusColor = Colors.red;
        tooltip = 'Sync failed';
        break;

      case TaskSyncIndicator.synced:
      case TaskSyncIndicator.idle:
        icon = pendingCount > 0
            ? Icons.cloud_upload_outlined
            : Icons.cloud_done_outlined;
        statusColor = pendingCount > 0 ? Colors.orange : Colors.green;
        tooltip = pendingCount > 0
            ? '$pendingCount changes pending'
            : 'Synced all';
    }

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: () => context.read<TaskBloc>().add(SyncRequested()),
        icon: Badge(
          isLabelVisible: pendingCount > 0,
          label: Text('$pendingCount'),
          backgroundColor: Colors.white,
          textColor: const Color(0xFF0891F4),
          child: Icon(
            icon,
            color: iconColor ?? statusColor,
          ),
        ),
      ),
    );
  }
}