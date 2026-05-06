import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/issue_model.dart';
import '../models/sync_queue_item.dart';

class IssueLocalService {
  static const String issuesKey = 'issues';
  static const String syncQueueKey = 'sync_queue';

  Future<List<IssueModel>> getIssues() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(issuesKey);

    if (data == null) return [];

    final List decoded = jsonDecode(data);
    return decoded.map((e) => IssueModel.fromJson(e)).toList();
  }

  Future<void> saveIssues(List<IssueModel> issues) async {
    final prefs = await SharedPreferences.getInstance();

    final data = jsonEncode(issues.map((e) => e.toJson()).toList());

    await prefs.setString(issuesKey, data);
  }

  Future<List<SyncQueueItem>> getSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(syncQueueKey);

    if (data == null) return [];

    final List decoded = jsonDecode(data);
    return decoded.map((e) => SyncQueueItem.fromJson(e)).toList();
  }

  Future<void> saveSyncQueue(List<SyncQueueItem> queue) async {
    final prefs = await SharedPreferences.getInstance();

    final data = jsonEncode(queue.map((e) => e.toJson()).toList());

    await prefs.setString(syncQueueKey, data);
  }

  Future<void> clearSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(syncQueueKey);
  }
}
