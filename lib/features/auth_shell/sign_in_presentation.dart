import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_text_field.dart';
import '../../core/theme/app_spacing.dart';
import 'auth_layout.dart';

/// Sign In visual presentation layout (no Firebase Auth coupling).
class SignInPresentation extends StatelessWidget {
  const SignInPresentation({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Welcome Back',
      subtitle: 'Sign in to access your Dayflow HR workspace',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppTextField(
            label: 'Work Email',
            hintText: 'name@company.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(
            label: 'Password',
            hintText: '••••••••',
            isPassword: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton.text(
              label: 'Forgot password?',
              onPressed: () => context.go('/auth/forgot-password'),
              size: AppButtonSize.small,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Sign In',
            isFullWidth: true,
            onPressed: () => context.go('/dashboard'),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              AppButton.text(
                label: 'Sign Up',
                onPressed: () => context.go('/auth/register'),
                size: AppButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
