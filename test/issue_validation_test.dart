import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_issue_tracker/models/issue_model.dart';
import 'package:mobile_issue_tracker/models/sync_queue_item.dart';
import 'package:mobile_issue_tracker/providers/auth_provider.dart';
import 'package:mobile_issue_tracker/providers/issue_provider.dart';
import 'package:mobile_issue_tracker/screens/issue_detail_screen.dart';
import 'package:mobile_issue_tracker/screens/issue_form_screen.dart';
import 'package:mobile_issue_tracker/screens/issue_list_screen.dart';
import 'package:mobile_issue_tracker/screens/login_screen.dart';
import 'package:mobile_issue_tracker/services/auth_service.dart';
import 'package:mobile_issue_tracker/services/issue_local_service.dart';
import 'package:mobile_issue_tracker/services/issue_mock_api_service.dart';
import 'package:mobile_issue_tracker/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Login validation', () {
    test('email should contain @', () {
      expect(AppValidators.email('testgmail.com'), 'Enter a valid email');
      expect(AppValidators.email('test@gmail.com'), isNull);
    });

    test('password should have minimum 6 characters', () {
      expect(AppValidators.password('12345'), 'Minimum 6 characters required');
      expect(AppValidators.password('123456'), isNull);
    });

    testWidgets('shows validation messages while typing', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService()),
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      expect(find.text('Enter a valid email'), findsNothing);
      expect(find.text('Minimum 6 characters required'), findsNothing);

      await tester.enterText(find.byType(TextFormField).at(0), 'testgmail.com');
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(1), '12345');
      await tester.pump();

      expect(find.text('Minimum 6 characters required'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService()),
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      TextField passwordField = tester.widget(find.byType(TextField).at(1));
      expect(passwordField.obscureText, isTrue);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();

      passwordField = tester.widget(find.byType(TextField).at(1));
      expect(passwordField.obscureText, isFalse);

      await tester.tap(find.byTooltip('Hide password'));
      await tester.pump();

      passwordField = tester.widget(find.byType(TextField).at(1));
      expect(passwordField.obscureText, isTrue);
    });
  });

  group('Issue form validation', () {
    test('title and description should not be empty', () {
      expect(AppValidators.issueTitle(''), 'Title is required');
      expect(AppValidators.issueDescription('  '), 'Description is required');
      expect(AppValidators.issueTitle('Crash on login'), isNull);
      expect(AppValidators.issueDescription('Steps to reproduce'), isNull);
    });

    testWidgets('shows required field messages while editing', (tester) async {
      final provider = IssueProvider(
        localService: IssueLocalService(),
        apiService: IssueMockApiService(),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: IssueFormScreen()),
        ),
      );

      expect(find.text('Title is required'), findsNothing);
      expect(find.text('Description is required'), findsNothing);

      await tester.enterText(find.byType(TextFormField).at(0), 'A title');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.pump();

      expect(find.text('Title is required'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(1), 'A description');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(1), '');
      await tester.pump();

      expect(find.text('Description is required'), findsOneWidget);
    });
  });

  group('Offline sync queue', () {
    test('new issue is saved locally and queued for sync', () async {
      final provider = IssueProvider(
        localService: IssueLocalService(),
        apiService: IssueMockApiService(),
      );
      final now = DateTime.now().toIso8601String();

      await provider.addIssue(
        IssueModel(
          id: 'local_1',
          title: 'Offline issue',
          description: 'Created without network',
          priority: 'High',
          status: 'Open',
          createdDate: now,
          updatedDate: now,
        ),
      );

      expect(provider.issues.single.isSynced, isFalse);
      expect(provider.pendingSyncCount, 1);

      await provider.syncPendingChanges();

      expect(provider.pendingSyncCount, 0);
      expect(provider.issues.single.isSynced, isTrue);
    });

    test('deleting an unsynced new issue clears its pending create', () async {
      final provider = IssueProvider(
        localService: IssueLocalService(),
        apiService: IssueMockApiService(),
      );
      final now = DateTime.now().toIso8601String();

      await provider.addIssue(
        IssueModel(
          id: 'local_delete_1',
          title: 'Temporary issue',
          description: 'Created and removed before sync',
          priority: 'Low',
          status: 'Open',
          createdDate: now,
          updatedDate: now,
        ),
      );

      await provider.deleteIssue('local_delete_1');

      expect(provider.issues, isEmpty);
      expect(provider.syncQueue, isEmpty);
      expect(provider.pendingSyncCount, 0);
    });

    test('deleting a synced issue is queued for sync', () async {
      final provider = IssueProvider(
        localService: IssueLocalService(),
        apiService: IssueMockApiService(),
      );

      await provider.loadIssues();
      await provider.deleteIssue('api_1');

      expect(provider.issues.any((issue) => issue.id == 'api_1'), isFalse);
      expect(provider.pendingSyncCount, 1);
      expect(provider.syncQueue.single.action, SyncQueueItem.deleteAction);
    });
  });

  testWidgets('shows fallback when detail issue no longer exists', (
    tester,
  ) async {
    final provider = IssueProvider(
      localService: IssueLocalService(),
      apiService: IssueMockApiService(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: IssueDetailScreen(issueId: 'missing_issue'),
        ),
      ),
    );

    expect(find.text('Issue not found'), findsOneWidget);
    expect(
      find.text('This issue may have been deleted or refreshed.'),
      findsOneWidget,
    );
  });

  testWidgets('creates an issue from the list screen flow', (tester) async {
    final provider = IssueProvider(
      localService: IssueLocalService(),
      apiService: IssueMockApiService(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: IssueListScreen()),
      ),
    );

    expect(find.text('No issues found'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Widget flow');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Create issue from the form',
    );

    final createButton = find.widgetWithText(FilledButton, 'Create Issue');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(find.text('Widget flow'), findsOneWidget);
    expect(provider.pendingSyncCount, 1);
    expect(find.text('1 local change waiting to sync'), findsOneWidget);
  });

  testWidgets('deletes an issue from the list after confirmation', (
    tester,
  ) async {
    final provider = IssueProvider(
      localService: IssueLocalService(),
      apiService: IssueMockApiService(),
    );
    final now = DateTime.now().toIso8601String();

    await provider.addIssue(
      IssueModel(
        id: 'delete_flow_1',
        title: 'Delete flow',
        description: 'Delete issue from the card menu',
        priority: 'Medium',
        status: 'Open',
        createdDate: now,
        updatedDate: now,
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: IssueListScreen()),
      ),
    );

    await tester.tap(find.byTooltip('Issue options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('Delete issue?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete flow'), findsNothing);
    expect(find.text('No issues found'), findsOneWidget);
    expect(provider.pendingSyncCount, 0);
  });
}
