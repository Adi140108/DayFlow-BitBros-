import 'package:flutter/material.dart';
import '../../core/components/app_badge.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class EmployeeOnboardingScreen extends StatelessWidget {
  const EmployeeOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Employee Onboarding Checklist', style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Track completion of mandatory onboarding milestones.',
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        _buildStepCard(
          context,
          stepNumber: 1,
          title: 'Account & Identity Activation',
          description: 'Firebase Auth account invitation & email verification',
          isCompleted: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildStepCard(
          context,
          stepNumber: 2,
          title: 'Personal & Emergency Information',
          description: 'Complete phone, residential address, emergency contacts',
          isCompleted: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildStepCard(
          context,
          stepNumber: 3,
          title: 'Mandatory HR Documents',
          description: 'Upload identity proof and educational certificates (Backblaze B2)',
          isCompleted: false,
          actionLabel: 'Upload Documents',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildStepCard(
          context,
          stepNumber: 4,
          title: 'HR Review & Activation',
          description: 'Final verification by Organization HR Manager',
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required String description,
    required bool isCompleted,
    String? actionLabel,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.successContainer : (isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 20, color: AppColors.success)
                  : Text('$stepNumber', style: AppTypography.label),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (isCompleted)
            const AppStatusBadge.success(label: 'COMPLETED')
          else if (actionLabel != null)
            AppButton(label: actionLabel, size: AppButtonSize.small, onPressed: () {})
          else
            const AppStatusBadge(label: 'PENDING', variant: AppBadgeVariant.neutral),
        ],
      ),
    );
  }
}
