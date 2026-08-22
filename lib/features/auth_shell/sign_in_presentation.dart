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
      subtitle: 'Sign in to access your Dayflow HR workspace',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Work Email',
            hintText: 'name@company.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Password',
            hintText: '••••••••',
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
            Text(
              _error!,
              style: AppTypography.caption.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Sign In',
            isFullWidth: true,
            isLoading: _isLoading,
            onPressed: _handleSignIn,
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
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}
