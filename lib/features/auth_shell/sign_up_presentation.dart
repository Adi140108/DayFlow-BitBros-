import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_text_field.dart';
import '../../core/theme/app_spacing.dart';
import 'auth_layout.dart';

/// Sign Up visual presentation layout (no Firebase Auth coupling).
class SignUpPresentation extends StatelessWidget {
  const SignUpPresentation({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create Account',
      subtitle: 'Set up your Dayflow profile',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppTextField(
            label: 'Full Name',
            hintText: 'Jane Doe',
          ),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(
            label: 'Work Email',
            hintText: 'name@company.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(
            label: 'Password',
            hintText: 'At least 8 characters',
            isPassword: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Create Account',
            isFullWidth: true,
            onPressed: () => context.go('/auth/verify'),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account?'),
              AppButton.text(
                label: 'Sign In',
                onPressed: () => context.go('/auth/login'),
                size: AppButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
