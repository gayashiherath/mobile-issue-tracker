import 'package:flutter/material.dart';

class SyncStatusBanner extends StatelessWidget {
  final int pendingCount;
  final bool isSyncing;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const SyncStatusBanner({
    super.key,
    required this.pendingCount,
    required this.isSyncing,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSyncing && pendingCount == 0 && errorMessage == null) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final hasError = errorMessage != null;
    final backgroundColor = hasError
        ? colorScheme.errorContainer
        : colorScheme.secondaryContainer;
    final foregroundColor = hasError
        ? colorScheme.onErrorContainer
        : colorScheme.onSecondaryContainer;
    final message = isSyncing
        ? 'Syncing local changes'
        : errorMessage ?? _pendingText(pendingCount);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            hasError ? Icons.error_outline : Icons.cloud_upload_outlined,
            color: foregroundColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: foregroundColor)),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: isSyncing ? null : onRetry,
            icon: isSyncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(hasError ? 'Retry' : 'Sync'),
          ),
        ],
      ),
    );
  }

  String _pendingText(int count) {
    if (count == 1) return '1 local change waiting to sync';
    return '$count local changes waiting to sync';
  }
}
