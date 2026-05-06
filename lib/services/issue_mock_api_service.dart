import '../models/issue_model.dart';
import '../models/sync_queue_item.dart';

class IssueMockApiService {
  Future<List<IssueModel>> fetchIssues() async {
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now().toIso8601String();

    return [
      IssueModel(
        id: 'api_1',
        title: 'Login button not responding',
        description: 'User cannot login after entering correct credentials.',
        priority: 'High',
        status: 'Open',
        assignee: 'Kasuni',
        createdDate: now,
        updatedDate: now,
        isSynced: true,
      ),
      IssueModel(
        id: 'api_2',
        title: 'Dashboard count mismatch',
        description: 'Resolved count is showing wrong value.',
        priority: 'Medium',
        status: 'In Progress',
        assignee: 'Nimal',
        createdDate: now,
        updatedDate: now,
        isSynced: true,
      ),
      IssueModel(
        id: 'api_3',
        title: 'Dark mode text color issue',
        description: 'Some labels are not readable in dark mode.',
        priority: 'Low',
        status: 'Resolved',
        assignee: 'Amal',
        createdDate: now,
        updatedDate: now,
        isSynced: true,
      ),
    ];
  }

  Future<void> syncQueue(List<SyncQueueItem> queue) async {
    await Future.delayed(const Duration(milliseconds: 700));
  }
}
