import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/components/app_button.dart';
import '../../core/theme/app_spacing.dart';
import 'auth_layout.dart';

/// Email verification presentation component.
class VerificationPresentation extends StatelessWidget {
  const VerificationPresentation({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Verify Your Email',
      subtitle: 'We sent a verification link to your work email address.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            size: 64,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Resend Verification Email',
            isFullWidth: true,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton.text(
            label: 'Back to Sign In',
            isFullWidth: true,
            onPressed: () => context.go('/auth/login'),
          ),
        ],
      ),
    );
  }
}
