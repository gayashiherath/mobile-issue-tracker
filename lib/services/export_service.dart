import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/issue_model.dart';

enum ExportFormat { json, csv }

class ExportService {
  Future<void> exportIssuesToJson(
    List<IssueModel> issues, {
    required BuildContext shareContext,
  }) async {
    await exportIssues(
      issues,
      shareContext: shareContext,
      format: ExportFormat.json,
    );
  }

  Future<void> exportIssuesToCsv(
    List<IssueModel> issues, {
    required BuildContext shareContext,
  }) async {
    await exportIssues(
      issues,
      shareContext: shareContext,
      format: ExportFormat.csv,
    );
  }

  Future<void> exportIssues(
    List<IssueModel> issues, {
    required BuildContext shareContext,
    required ExportFormat format,
  }) async {
    final sharePositionOrigin = _sharePositionOrigin(shareContext);
    final directory = await getApplicationDocumentsDirectory();

    final file = File('${directory.path}/${_fileNameFor(format)}');

    await file.writeAsString(_contentFor(issues, format));

    await Share.shareXFiles(
      [XFile(file.path, mimeType: _mimeTypeFor(format))],
      text: 'Issue Tracker ${_labelFor(format)} Export',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  Rect? _sharePositionOrigin(BuildContext context) {
    final renderObject = context.findRenderObject();

    if (renderObject is RenderBox && renderObject.hasSize) {
      final size = renderObject.size;
      if (!size.isEmpty) {
        return renderObject.localToGlobal(Offset.zero) & size;
      }
    }

    final mediaQuery = MediaQuery.maybeOf(context);
    final viewSize = mediaQuery?.size;
    if (viewSize == null || viewSize.isEmpty) {
      return null;
    }

    return Offset.zero & viewSize;
  }

  String _contentFor(List<IssueModel> issues, ExportFormat format) {
    return switch (format) {
      ExportFormat.json => const JsonEncoder.withIndent(
        '  ',
      ).convert(issues.map((e) => e.toJson()).toList()),
      ExportFormat.csv => _toCsv(issues),
    };
  }

  String _toCsv(List<IssueModel> issues) {
    final rows = [
      [
        'id',
        'title',
        'description',
        'priority',
        'status',
        'assignee',
        'createdDate',
        'updatedDate',
        'attachmentPath',
        'isSynced',
      ],
      ...issues.map(
        (issue) => [
          issue.id,
          issue.title,
          issue.description,
          issue.priority,
          issue.status,
          issue.assignee ?? '',
          issue.createdDate,
          issue.updatedDate,
          issue.attachmentPath ?? '',
          issue.isSynced.toString(),
        ],
      ),
    ];

    return rows.map((row) => row.map(_escapeCsv).join(',')).join('\n');
  }

  String _escapeCsv(String value) {
    if (!value.contains(',') && !value.contains('"') && !value.contains('\n')) {
      return value;
    }

    return '"${value.replaceAll('"', '""')}"';
  }

  String _fileNameFor(ExportFormat format) {
    return switch (format) {
      ExportFormat.json => 'issues_export.json',
      ExportFormat.csv => 'issues_export.csv',
    };
  }

  String _mimeTypeFor(ExportFormat format) {
    return switch (format) {
      ExportFormat.json => 'application/json',
      ExportFormat.csv => 'text/csv',
    };
  }

  String _labelFor(ExportFormat format) {
    return switch (format) {
      ExportFormat.json => 'JSON',
      ExportFormat.csv => 'CSV',
    };
  }
}
