import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/issue_provider.dart';
import '../services/export_service.dart';
import '../widgets/issue_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/sync_status_banner.dart';
import 'issue_detail_screen.dart';
import 'issue_form_screen.dart';

class IssueListScreen extends StatelessWidget {
  const IssueListScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;

    await context.read<AuthProvider>().logout();
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

    await context.read<IssueProvider>().deleteIssue(issueId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IssueProvider>();
    final appBarForegroundColor = Theme.of(context).appBarTheme.foregroundColor;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issues'),
        actions: [
          PopupMenuButton<ExportFormat>(
            icon: Icon(Icons.ios_share, color: appBarForegroundColor),
            tooltip: 'Export issues',
            onSelected: (format) async {
              await ExportService().exportIssues(
                provider.issues,
                shareContext: context,
                format: format,
              );
            },
            itemBuilder: (context) {
              final menuTextColor = Theme.of(context).colorScheme.onSurface;

              return [
                PopupMenuItem(
                  value: ExportFormat.json,
                  child: Row(
                    children: [
                      Icon(Icons.data_object, color: menuTextColor),
                      const SizedBox(width: 10),
                      Text('JSON', style: TextStyle(color: menuTextColor)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ExportFormat.csv,
                  child: Row(
                    children: [
                      Icon(Icons.table_chart_outlined, color: menuTextColor),
                      const SizedBox(width: 10),
                      Text('CSV', style: TextStyle(color: menuTextColor)),
                    ],
                  ),
                ),
              ];
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () {
              _confirmLogout(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Create'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IssueFormScreen()),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<IssueProvider>().refreshFromApi(),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.errorMessage != null
            ? ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  SyncStatusBanner(
                    pendingCount: provider.pendingSyncCount,
                    isSyncing: provider.isSyncing,
                    errorMessage: provider.syncErrorMessage,
                    onRetry: () {
                      context.read<IssueProvider>().syncPendingChanges();
                    },
                  ),
                  Text(provider.errorMessage!),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      context.read<IssueProvider>().loadIssues();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  SyncStatusBanner(
                    pendingCount: provider.pendingSyncCount,
                    isSyncing: provider.isSyncing,
                    errorMessage: provider.syncErrorMessage,
                    onRetry: () {
                      context.read<IssueProvider>().syncPendingChanges();
                    },
                  ),
                  Row(
                    children: [
                      SummaryCard(
                        title: 'Open',
                        count: provider.openCount,
                        icon: Icons.radio_button_unchecked,
                        accentColor: colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      SummaryCard(
                        title: 'Progress',
                        count: provider.inProgressCount,
                        icon: Icons.timelapse,
                        accentColor: const Color(0xFF5F6DCC),
                      ),
                      const SizedBox(width: 10),
                      SummaryCard(
                        title: 'Resolved',
                        count: provider.resolvedCount,
                        icon: Icons.check_circle_outline,
                        accentColor: const Color(0xFF2D8C67),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: provider.updateSearch,
                    decoration: const InputDecoration(
                      hintText: 'Search by title',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: provider.selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items:
                              const [
                                    'All',
                                    'Open',
                                    'In Progress',
                                    'Resolved',
                                    'Closed',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            provider.updateStatusFilter(value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: provider.selectedPriority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                          ),
                          items: const ['All', 'Low', 'Medium', 'High']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (value) {
                            provider.updatePriorityFilter(value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (provider.filteredIssues.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 42,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No issues found',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...provider.filteredIssues.map(
                      (issue) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: IssueCard(
                          issue: issue,
                          onDelete: () {
                            _confirmDeleteIssue(context, issue.id);
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    IssueDetailScreen(issueId: issue.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
