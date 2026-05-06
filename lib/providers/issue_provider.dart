import 'package:flutter/material.dart';

import '../models/issue_model.dart';
import '../models/sync_queue_item.dart';
import '../services/issue_local_service.dart';
import '../services/issue_mock_api_service.dart';

class IssueProvider extends ChangeNotifier {
  final IssueLocalService localService;
  final IssueMockApiService apiService;

  IssueProvider({required this.localService, required this.apiService});

  List<IssueModel> _issues = [];
  List<SyncQueueItem> _syncQueue = [];
  bool isLoading = false;
  bool isSyncing = false;
  String? errorMessage;
  String? syncErrorMessage;
  String? syncMessage;

  String searchText = '';
  String selectedStatus = 'All';
  String selectedPriority = 'All';

  List<IssueModel> get issues => _issues;
  List<SyncQueueItem> get syncQueue => List.unmodifiable(_syncQueue);

  int get pendingSyncCount {
    if (_syncQueue.isNotEmpty) return _syncQueue.length;
    return _issues.where((issue) => !issue.isSynced).length;
  }

  bool get hasPendingSync => pendingSyncCount > 0;

  List<IssueModel> get filteredIssues {
    return _issues.where((issue) {
      final matchesSearch = issue.title.toLowerCase().contains(
        searchText.toLowerCase(),
      );

      final matchesStatus =
          selectedStatus == 'All' || issue.status == selectedStatus;

      final matchesPriority =
          selectedPriority == 'All' || issue.priority == selectedPriority;

      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  int get openCount => _issues.where((e) => e.status == 'Open').length;

  int get inProgressCount =>
      _issues.where((e) => e.status == 'In Progress').length;

  int get resolvedCount => _issues.where((e) => e.status == 'Resolved').length;

  Future<void> loadIssues() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _syncQueue = await localService.getSyncQueue();
      final localIssues = await localService.getIssues();

      if (localIssues.isEmpty && _syncQueue.isEmpty) {
        final apiIssues = await apiService.fetchIssues();
        _issues = apiIssues;
        await localService.saveIssues(_issues);
      } else {
        _issues = localIssues;
      }
    } catch (_) {
      errorMessage = 'Failed to load issues';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshFromApi() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final apiIssues = await apiService.fetchIssues();

      final pendingIssueIds = _syncQueue.map((e) => e.issueId).toSet();
      final pendingDeleteIds = _syncQueue
          .where((e) => e.action == SyncQueueItem.deleteAction)
          .map((e) => e.issueId)
          .toSet();
      final pendingIssues = _issues
          .where((e) => !e.isSynced || pendingIssueIds.contains(e.id))
          .toList();
      final localSyncedIssues = _issues
          .where((e) => e.isSynced && !e.id.startsWith('api_'))
          .toList();
      final protectedIds = {
        ...pendingIssues.map((e) => e.id),
        ...localSyncedIssues.map((e) => e.id),
        ...pendingDeleteIds,
      };

      final merged = [
        ...pendingIssues,
        ...apiIssues.where((apiIssue) => !protectedIds.contains(apiIssue.id)),
        ...localSyncedIssues.where(
          (localIssue) => !pendingIssues.any((e) => e.id == localIssue.id),
        ),
      ];

      _issues = merged.isEmpty && pendingDeleteIds.isEmpty ? apiIssues : merged;
      await localService.saveIssues(_issues);
    } catch (_) {
      errorMessage = 'Refresh failed. Showing offline data.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addIssue(IssueModel issue) async {
    final pendingIssue = issue.copyWith(isSynced: false);

    _issues.insert(0, pendingIssue);
    _enqueueChange(SyncQueueItem.createAction, pendingIssue);
    await _persistLocalState();
    notifyListeners();
  }

  Future<void> updateIssue(IssueModel updatedIssue) async {
    final index = _issues.indexWhere((e) => e.id == updatedIssue.id);

    if (index != -1) {
      final issue = updatedIssue.copyWith(
        updatedDate: DateTime.now().toIso8601String(),
        isSynced: false,
      );

      _issues[index] = issue;
      _enqueueChange(SyncQueueItem.updateAction, issue);
      await _persistLocalState();
      notifyListeners();
    }
  }

  Future<void> markAsResolved(String id) async {
    final index = _issues.indexWhere((e) => e.id == id);

    if (index != -1) {
      final issue = _issues[index].copyWith(
        status: 'Resolved',
        updatedDate: DateTime.now().toIso8601String(),
        isSynced: false,
      );

      _issues[index] = issue;
      _enqueueChange(SyncQueueItem.resolveAction, issue);
      await _persistLocalState();
      notifyListeners();
    }
  }

  Future<void> markAsClosed(String id) async {
    final index = _issues.indexWhere((e) => e.id == id);

    if (index != -1) {
      final issue = _issues[index].copyWith(
        status: 'Closed',
        updatedDate: DateTime.now().toIso8601String(),
        isSynced: false,
      );

      _issues[index] = issue;
      _enqueueChange(SyncQueueItem.closeAction, issue);
      await _persistLocalState();
      notifyListeners();
    }
  }

  Future<void> deleteIssue(String id) async {
    final index = _issues.indexWhere((e) => e.id == id);

    if (index != -1) {
      final issue = _issues.removeAt(index);
      final hasPendingCreate = _syncQueue.any(
        (item) =>
            item.issueId == issue.id &&
            item.action == SyncQueueItem.createAction,
      );

      syncMessage = null;
      syncErrorMessage = null;
      _syncQueue.removeWhere((item) => item.issueId == issue.id);

      if (!hasPendingCreate) {
        _syncQueue.add(_queueItemFor(SyncQueueItem.deleteAction, issue));
      }

      await _persistLocalState();
      notifyListeners();
    }
  }

  Future<void> syncPendingChanges() async {
    final queueToSync = _syncQueue.isNotEmpty
        ? List<SyncQueueItem>.from(_syncQueue)
        : _issues
              .where((issue) => !issue.isSynced)
              .map((issue) => _queueItemFor(SyncQueueItem.updateAction, issue))
              .toList();

    if (queueToSync.isEmpty) {
      syncErrorMessage = null;
      syncMessage = 'No local changes to sync';
      notifyListeners();
      return;
    }

    isSyncing = true;
    syncErrorMessage = null;
    syncMessage = null;
    notifyListeners();

    try {
      await apiService.syncQueue(queueToSync);

      final syncedIds = queueToSync.map((item) => item.issueId).toSet();
      _issues = _issues.map((issue) {
        if (!syncedIds.contains(issue.id)) return issue;
        return issue.copyWith(isSynced: true);
      }).toList();

      _syncQueue = [];
      await localService.saveIssues(_issues);
      await localService.clearSyncQueue();
      syncMessage = 'All local changes synced';
    } catch (_) {
      syncErrorMessage = 'Sync failed. Check your connection and retry.';
    }

    isSyncing = false;
    notifyListeners();
  }

  void updateSearch(String value) {
    searchText = value;
    notifyListeners();
  }

  void updateStatusFilter(String value) {
    selectedStatus = value;
    notifyListeners();
  }

  void updatePriorityFilter(String value) {
    selectedPriority = value;
    notifyListeners();
  }

  void _enqueueChange(String action, IssueModel issue) {
    syncMessage = null;
    syncErrorMessage = null;
    _syncQueue.add(_queueItemFor(action, issue));
  }

  SyncQueueItem _queueItemFor(String action, IssueModel issue) {
    final queuedAt = DateTime.now().toIso8601String();

    return SyncQueueItem(
      id: '${DateTime.now().microsecondsSinceEpoch}_${issue.id}',
      issueId: issue.id,
      action: action,
      queuedAt: queuedAt,
      payload: issue.toJson(),
    );
  }

  Future<void> _persistLocalState() async {
    await localService.saveIssues(_issues);
    await localService.saveSyncQueue(_syncQueue);
  }
}
