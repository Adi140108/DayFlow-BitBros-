import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_text_field.dart';
import '../../core/theme/app_spacing.dart';
import 'auth_layout.dart';

/// Forgot password presentation component.
class ForgotPasswordPresentation extends StatelessWidget {
  const ForgotPasswordPresentation({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Reset Password',
      subtitle: 'Enter your work email to receive a password reset link',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppTextField(
            label: 'Work Email',
            hintText: 'name@company.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Send Reset Link',
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
