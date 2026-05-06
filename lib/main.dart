import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/issue_provider.dart';
import 'screens/login_screen.dart';
import 'screens/issue_list_screen.dart';
import 'services/auth_service.dart';
import 'services/issue_local_service.dart';
import 'services/issue_mock_api_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const IssueTrackerApp());
}

class IssueTrackerApp extends StatelessWidget {
  const IssueTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService())..checkLogin(),
        ),
        ChangeNotifierProvider(
          create: (_) => IssueProvider(
            localService: IssueLocalService(),
            apiService: IssueMockApiService(),
          )..loadIssues(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Issue Tracker',
        themeMode: ThemeMode.system,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoggedIn) {
              return const IssueListScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
