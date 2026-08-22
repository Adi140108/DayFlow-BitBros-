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

import '../../core/components/app_select.dart';

/// Sign Up visual presentation layout connected to Firebase Auth.
class SignUpPresentation extends ConsumerStatefulWidget {
  const SignUpPresentation({super.key});

  @override
  ConsumerState<SignUpPresentation> createState() => _SignUpPresentationState();
}

class _SignUpPresentationState extends ConsumerState<SignUpPresentation> {
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'employee';
  bool _isLoading = false;
  String? _error;

  final List<DropdownMenuItem<String>> _roleItems = const [
    DropdownMenuItem(value: 'employee', child: Text('Employee (Regular User)')),
    DropdownMenuItem(value: 'hr_manager', child: Text('HR Officer / HR Manager')),
    DropdownMenuItem(value: 'owner', child: Text('Admin / Organization Owner')),
  ];

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create Account',
      subtitle: 'Create your Dayflow account to get started',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Full Name',
            hintText: 'e.g. Jane Doe',
            controller: _nameController,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Employee ID (Optional)',
            hintText: 'e.g. EMP-001 (or auto-assigned)',
            controller: _employeeIdController,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Email',
            hintText: 'you@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdown<String>(
            label: 'Role (Employee / HR / Admin)',
            value: _selectedRole,
            items: _roleItems,
            onChanged: (val) {
              if (val != null) setState(() => _selectedRole = val);
            },
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
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _error!,
                style: AppTypography.caption.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
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

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'Please enter a valid email address (e.g. name@gmail.com).');
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
      final errStr = e.toString();
      String userMsg = errStr;
      if (errStr.contains('email-already-in-use') || errStr.contains('already exists')) {
        userMsg = 'An account with this email already exists. Please click "Sign In" below to log in.';
      }
      setState(() {
        _error = userMsg;
        _isLoading = false;
      });
    }
  }
}
