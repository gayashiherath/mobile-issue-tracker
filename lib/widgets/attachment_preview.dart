import 'dart:io';

import 'package:flutter/material.dart';

class AttachmentPreview extends StatelessWidget {
  final String? attachmentPath;
  final double height;

  const AttachmentPreview({
    super.key,
    required this.attachmentPath,
    this.height = 180,
  });

  bool get hasAttachment =>
      attachmentPath != null && attachmentPath!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!hasAttachment) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final file = File(attachmentPath!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attachment', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: height,
            width: double.infinity,
            color: colorScheme.surfaceContainerHighest,
            child: file.existsSync()
                ? Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  )
                : Icon(
                    Icons.image_not_supported_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
      ],
    );
  }
}
