import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/settings_screen.dart';
import '../providers/auth_provider.dart';

import '../screens/post_intervention_review_screen.dart';
import '../models/task.dart';

import '../screens/report_bts_failure_screen.dart';
import '../screens/new_bts_site_request_screen.dart';
import '../screens/customer_satisfaction_survey_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool loggedIn = authProvider.isAuthenticated;
        final bool loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        if (!loggedIn) {
          return loggingIn ? null : '/login';
        }

        if (loggingIn) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const MainScreen(initialIndex: 0),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => const MainScreen(initialIndex: 1),
        ),
        GoRoute(
          path: '/forms',
          builder: (context, state) => const MainScreen(initialIndex: 2),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const MainScreen(initialIndex: 3),
        ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TasksScreen(),
        ),
        GoRoute(
          path: '/task-review',
          builder: (context, state) {
            final task = state.extra as Task?;
            return PostInterventionReviewScreen(task: task);
          },
        ),
        GoRoute(
          path: '/report-failure',
          builder: (context, state) => const ReportBtsFailureScreen(),
        ),
        GoRoute(
          path: '/new-bts-site',
          builder: (context, state) => const NewBtsSiteRequestScreen(),
        ),
        GoRoute(
          path: '/survey',
          builder: (context, state) => const CustomerSatisfactionSurveyScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }
}
