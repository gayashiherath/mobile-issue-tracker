import 'dart:io';

import 'package:flutter/material.dart';

class AttachmentPickerTile extends StatelessWidget {
  final String? attachmentPath;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  const AttachmentPickerTile({
    super.key,
    required this.attachmentPath,
    required this.onPick,
    this.onRemove,
  });

  bool get hasAttachment =>
      attachmentPath != null && attachmentPath!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            Theme.of(context).inputDecorationTheme.fillColor ??
            colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          _AttachmentThumbnail(path: attachmentPath),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAttachment ? _fileName(attachmentPath!) : 'Attachment',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  hasAttachment ? 'Image attached' : 'Add image',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: hasAttachment ? 'Change image' : 'Add image',
            onPressed: onPick,
            icon: Icon(
              hasAttachment ? Icons.image_search : Icons.add_photo_alternate,
            ),
          ),
          if (hasAttachment)
            IconButton(
              tooltip: 'Remove image',
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }

  String _fileName(String path) {
    final parts = path.split('/').where((part) => part.isNotEmpty).toList();
    return parts.isEmpty ? path : parts.last;
  }
}

class _AttachmentThumbnail extends StatelessWidget {
  final String? path;

  const _AttachmentThumbnail({required this.path});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasPath = path != null && path!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 64,
        height: 64,
        color: colorScheme.surfaceContainerHighest,
        child: hasPath && File(path!).existsSync()
            ? Image.file(
                File(path!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              )
            : Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
