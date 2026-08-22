import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/firebase_auth_service.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'auth_layout.dart';

/// Email verification presentation component connected to Firebase Auth.
class VerificationPresentation extends ConsumerStatefulWidget {
  const VerificationPresentation({super.key});

  @override
  ConsumerState<VerificationPresentation> createState() => _VerificationPresentationState();
}

class _VerificationPresentationState extends ConsumerState<VerificationPresentation> {
  bool _isLoading = false;
  String? _message;

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
            color: AppColors.primary,
          ),
          if (_message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _message!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.info),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Resend Verification Email',
            isFullWidth: true,
            isLoading: _isLoading,
            onPressed: _resendVerification,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton.secondary(
            label: 'Check Verification Status',
            isFullWidth: true,
            onPressed: () async {
              final authService = FirebaseAuthService();
              await authService.reloadUser();
              final user = authService.currentUser;
              if (user != null && user.emailVerified) {
                ref.read(authNotifierProvider).signOut();
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton.text(
            label: 'Sign Out / Back to Sign In',
            isFullWidth: true,
            onPressed: () => ref.read(authNotifierProvider).signOut(),
          ),
        ],
      ),
    );
  }

  Future<void> _resendVerification() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await FirebaseAuthService().sendEmailVerification();
      setState(() {
        _message = 'Verification email resent successfully.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = e.toString();
        _isLoading = false;
      });
    }
  }
}
