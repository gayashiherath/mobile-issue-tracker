import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/issue_model.dart';
import '../providers/issue_provider.dart';
import '../widgets/attachment_preview.dart';
import 'issue_form_screen.dart';

class IssueDetailScreen extends StatelessWidget {
  final String issueId;

  const IssueDetailScreen({super.key, required this.issueId});

  IssueModel? _findIssue(List<IssueModel> issues) {
    for (final issue in issues) {
      if (issue.id == issueId) return issue;
    }

    return null;
  }

  Future<void> confirmAction({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      onConfirm();
    }
  }

  Future<void> _confirmDeleteIssue(BuildContext context, String issueId) async {
    final shouldDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Delete issue?'),
          content: const Text('This issue will be permanently deleted.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    final issueProvider = context.read<IssueProvider>();
    Navigator.pop(context);
    await issueProvider.deleteIssue(issueId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IssueProvider>();

    final issue = _findIssue(provider.issues);

    if (issue == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Issue Detail')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 44,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Issue not found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This issue may have been deleted or refreshed.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to issues'),
                  onPressed: Navigator.of(context).canPop()
                      ? () => Navigator.of(context).pop()
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final createdDate = DateFormat(
      'MMM dd, yyyy hh:mm a',
    ).format(DateTime.parse(issue.createdDate));

    final updatedDate = DateFormat(
      'MMM dd, yyyy hh:mm a',
    ).format(DateTime.parse(issue.updatedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit issue',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IssueFormScreen(issue: issue),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete issue',
            onPressed: () {
              _confirmDeleteIssue(context, issue.id);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(issue.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(issue.status)),
              Chip(label: Text(issue.priority)),
              if (!issue.isSynced)
                const Chip(
                  avatar: Icon(Icons.cloud_off, size: 18),
                  label: Text('Pending sync'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(issue.description),
          const SizedBox(height: 20),
          AttachmentPreview(attachmentPath: issue.attachmentPath),
          if (issue.attachmentPath != null &&
              issue.attachmentPath!.trim().isNotEmpty)
            const SizedBox(height: 20),
          Text('Assignee: ${issue.assignee ?? 'Not assigned'}'),
          const SizedBox(height: 8),
          Text('Created: $createdDate'),
          const SizedBox(height: 8),
          Text('Updated: $updatedDate'),
          const SizedBox(height: 30),
          FilledButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Mark as Resolved'),
            onPressed: issue.status == 'Resolved'
                ? null
                : () {
                    confirmAction(
                      context: context,
                      title: 'Resolve Issue',
                      message:
                          'Are you sure you want to mark this as resolved?',
                      onConfirm: () {
                        context.read<IssueProvider>().markAsResolved(issue.id);
                      },
                    );
                  },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.close),
            label: const Text('Close Issue'),
            onPressed: issue.status == 'Closed'
                ? null
                : () {
                    confirmAction(
                      context: context,
                      title: 'Close Issue',
                      message: 'Are you sure you want to close this issue?',
                      onConfirm: () {
                        context.read<IssueProvider>().markAsClosed(issue.id);
                      },
                    );
                  },
          ),
        ],
      ),
    );
  }
}
