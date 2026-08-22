import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/firebase_auth_service.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_text_field.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'auth_layout.dart';

/// Forgot password presentation component connected to Firebase Auth.
class ForgotPasswordPresentation extends StatefulWidget {
  const ForgotPasswordPresentation({super.key});

  @override
  State<ForgotPasswordPresentation> createState() => _ForgotPasswordPresentationState();
}

class _ForgotPasswordPresentationState extends State<ForgotPasswordPresentation> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Reset Password',
      subtitle: 'Enter your work email to receive a password reset link',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Work Email',
            hintText: 'name@company.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          if (_message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _message!,
              style: AppTypography.bodySmall.copyWith(
                color: _isSuccess ? AppColors.success : AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Send Reset Link',
            isFullWidth: true,
            isLoading: _isLoading,
            onPressed: _sendResetLink,
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

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _message = 'Please enter your work email.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await FirebaseAuthService().sendPasswordReset(email);
      setState(() {
        _message = 'Password reset link sent. Please check your inbox.';
        _isSuccess = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = e.toString();
        _isSuccess = false;
        _isLoading = false;
      });
    }
  }
}
