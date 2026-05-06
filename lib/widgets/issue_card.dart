import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/issue_model.dart';

enum _IssueCardAction { delete }

class IssueCard extends StatelessWidget {
  final IssueModel issue;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const IssueCard({
    super.key,
    required this.issue,
    required this.onTap,
    this.onDelete,
  });

  Color getPriorityColor() {
    switch (issue.priority) {
      case 'High':
        return const Color(0xFFD9485D);
      case 'Medium':
        return const Color(0xFFC77A18);
      default:
        return const Color(0xFF2D8C67);
    }
  }

  Color getStatusColor() {
    switch (issue.status) {
      case 'Open':
        return const Color(0xFFCE6078);
      case 'In Progress':
        return const Color(0xFF5F6DCC);
      case 'Resolved':
        return const Color(0xFF2D8C67);
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final priorityColor = getPriorityColor();
    final statusColor = getStatusColor();
    final date = DateFormat(
      'MMM dd, yyyy',
    ).format(DateTime.parse(issue.createdDate));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    issue.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (onDelete != null)
                  PopupMenuButton<_IssueCardAction>(
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'Issue options',
                    onSelected: (action) {
                      switch (action) {
                        case _IssueCardAction.delete:
                          onDelete?.call();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: _IssueCardAction.delete,
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline),
                            SizedBox(width: 10),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(issue.status),
                  backgroundColor: statusColor.withValues(alpha: 0.14),
                  labelStyle: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Chip(
                  label: Text(issue.priority),
                  backgroundColor: priorityColor.withValues(alpha: 0.14),
                  labelStyle: TextStyle(
                    color: priorityColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (issue.attachmentPath != null &&
                    issue.attachmentPath!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.attachment,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (!issue.isSynced)
                  const Icon(Icons.cloud_off, size: 18, color: Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
