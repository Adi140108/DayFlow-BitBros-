import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_notifier.dart';
import '../shell/app_shell.dart';
import '../../features/auth_shell/sign_in_presentation.dart';
import '../../features/auth_shell/sign_up_presentation.dart';
import '../../features/auth_shell/verification_presentation.dart';
import '../../features/auth_shell/forgot_password_presentation.dart';
import '../../features/organization/create_organization_screen.dart';
import '../../features/employees/employee_directory_screen.dart';
import '../../features/employees/employee_details_screen.dart';
import '../../features/attendance/employee_attendance_screen.dart';
import '../../features/attendance/hr_attendance_screen.dart';
import '../../features/leave/employee_leave_screen.dart';
import '../../features/leave/approval_dashboard_screen.dart';
import '../../features/design_system_preview/design_system_preview_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final session = authNotifier.state;
      final isAuthRoute = state.uri.toString().startsWith('/auth');
      final isOnboardingRoute = state.uri.toString() == '/onboarding/create-org';

      switch (session.status) {
        case AuthSessionStatus.initializing:
          return null;
        case AuthSessionStatus.unauthenticated:
        case AuthSessionStatus.error:
          if (!isAuthRoute) return '/auth/login';
          return null;
        case AuthSessionStatus.unverified:
          if (state.uri.toString() != '/auth/verify') return '/auth/verify';
          return null;
        case AuthSessionStatus.noOrganization:
          if (!isOnboardingRoute) return '/onboarding/create-org';
          return null;
        case AuthSessionStatus.authenticated:
          if (isAuthRoute || isOnboardingRoute) return '/dashboard';
          return null;
      }
    },
    routes: [
      // Auth Shell Presentation Routes
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const SignInPresentation(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const SignUpPresentation(),
      ),
      GoRoute(
        path: '/auth/verify',
        builder: (context, state) => const VerificationPresentation(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordPresentation(),
      ),

      // Onboarding Routes
      GoRoute(
        path: '/onboarding/create-org',
        builder: (context, state) => const CreateOrganizationScreen(),
      ),

      // Application Shell Routes
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(
            location: state.uri.toString(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const _PlaceholderPage(title: 'Dashboard'),
          ),
          GoRoute(
            path: '/employees',
            builder: (context, state) => const EmployeeDirectoryScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return EmployeeDetailsScreen(id: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/attendance',
            builder: (context, state) => const EmployeeAttendanceScreen(),
            routes: [
              GoRoute(
                path: 'manage',
                builder: (context, state) => const HRAttendanceScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/leave',
            builder: (context, state) => const EmployeeLeaveScreen(),
            routes: [
              GoRoute(
                path: 'approvals',
                builder: (context, state) => const ApprovalDashboardScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/payroll',
            builder: (context, state) => const _PlaceholderPage(title: 'Payroll Domain Placeholder'),
          ),
          GoRoute(
            path: '/documents',
            builder: (context, state) => const _PlaceholderPage(title: 'Documents Domain Placeholder'),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const _PlaceholderPage(title: 'Reports Domain Placeholder'),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const _PlaceholderPage(title: 'Analytics Domain Placeholder'),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const _PlaceholderPage(title: 'Notifications Domain Placeholder'),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const _PlaceholderPage(title: 'Settings Domain Placeholder'),
          ),
          GoRoute(
            path: '/design-system',
            builder: (context, state) => const DesignSystemPreviewPage(),
          ),
        ],
      ),
    ],
  );
});

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
