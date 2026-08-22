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

/// Sign Up visual presentation layout connected to Firebase Auth.
class SignUpPresentation extends ConsumerStatefulWidget {
  const SignUpPresentation({super.key});

  @override
  ConsumerState<SignUpPresentation> createState() => _SignUpPresentationState();
}

class _SignUpPresentationState extends ConsumerState<SignUpPresentation> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create Account',
      subtitle: 'Set up your Dayflow user identity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Full Name',
            hintText: 'Jane Doe',
            controller: _nameController,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Work Email',
            hintText: 'name@company.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Password',
            hintText: 'At least 8 characters',
            controller: _passwordController,
            isPassword: true,
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
            label: 'Create Account',
            isFullWidth: true,
            isLoading: _isLoading,
            onPressed: _handleSignUp,
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

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill out all fields.');
      return;
    }

    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authNotifierProvider).signUp(email, password, name);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}
