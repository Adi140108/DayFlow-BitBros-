import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_text_field.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'auth_layout.dart';

/// Sign In visual presentation layout connected to Firebase Auth.
class SignInPresentation extends ConsumerStatefulWidget {
  const SignInPresentation({super.key});

  @override
  ConsumerState<SignInPresentation> createState() => _SignInPresentationState();
}

class _SignInPresentationState extends ConsumerState<SignInPresentation> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Welcome Back',
      subtitle: 'Sign in to your Dayflow workspace',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Email',
            hintText: 'you@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Password',
            hintText: 'Enter your password',
            controller: _passwordController,
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
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      _error!,
                      style: AppTypography.caption.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Sign In',
            isFullWidth: true,
            isLoading: _isLoading,
            onPressed: _handleSignIn,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: AppTypography.bodySmall,
              ),
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

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authNotifierProvider).signIn(email, password);
    } catch (e) {
      final errStr = e.toString();
      String msg = errStr;
      if (errStr.contains('user-not-found') || errStr.contains('INVALID_LOGIN_CREDENTIALS')) {
        msg = 'No account found with this email. Please sign up first.';
      } else if (errStr.contains('wrong-password')) {
        msg = 'Incorrect password. Please try again.';
      } else if (errStr.contains('invalid-email')) {
        msg = 'Please enter a valid email address.';
      } else if (errStr.contains('too-many-requests')) {
        msg = 'Too many attempts. Please try again later.';
      }
      setState(() {
        _error = msg;
        _isLoading = false;
      });
    }
  }
}
