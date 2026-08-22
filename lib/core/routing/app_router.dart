import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shell/app_shell.dart';
import '../../features/auth_shell/sign_in_presentation.dart';
import '../../features/auth_shell/sign_up_presentation.dart';
import '../../features/auth_shell/verification_presentation.dart';
import '../../features/auth_shell/forgot_password_presentation.dart';
import '../../features/design_system_preview/design_system_preview_page.dart';

final GoRouter kAppRouter = GoRouter(
  initialLocation: '/dashboard',
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
          builder: (context, state) => const _PlaceholderPage(title: 'Employees Domain Placeholder'),
        ),
        GoRoute(
          path: '/attendance',
          builder: (context, state) => const _PlaceholderPage(title: 'Attendance Domain Placeholder'),
        ),
        GoRoute(
          path: '/leave',
          builder: (context, state) => const _PlaceholderPage(title: 'Leave Domain Placeholder'),
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
