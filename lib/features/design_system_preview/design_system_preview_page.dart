import 'package:flutter/material.dart';
import '../../core/components/app_avatar.dart';
import '../../core/components/app_badge.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/components/app_feedback.dart';
import '../../core/components/app_file_surface.dart';
import '../../core/components/app_overlay.dart';
import '../../core/components/app_select.dart';
import '../../core/components/app_table.dart';
import '../../core/components/app_text_field.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Developer-only Design System Preview Gallery for component visual verification.
class DesignSystemPreviewPage extends StatefulWidget {
  const DesignSystemPreviewPage({super.key});

  @override
  State<DesignSystemPreviewPage> createState() => _DesignSystemPreviewPageState();
}

class _DesignSystemPreviewPageState extends State<DesignSystemPreviewPage> {
  bool _checkboxVal = true;
  bool _switchVal = false;
  String? _dropdownVal = 'Option 1';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Design System & Component Gallery', style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Internal developer verification surface demonstrating all reusable UI primitives.',
          style: AppTypography.body,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Section 1: Buttons
        _buildSectionTitle('1. Buttons & Actions'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(label: 'Primary Button', onPressed: () {}),
            AppButton.secondary(label: 'Secondary Button', onPressed: () {}),
            AppButton.text(label: 'Text Button', onPressed: () {}),
            AppButton.destructive(label: 'Destructive Button', onPressed: () {}),
            const AppButton(label: 'Loading...', isLoading: true),
            const AppButton(label: 'Disabled'),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Section 2: Form Inputs
        _buildSectionTitle('2. Form Inputs & Selection Controls'),
        const Row(
          children: [
            Expanded(child: AppTextField(label: 'Standard Input', hintText: 'Enter text...')),
            SizedBox(width: AppSpacing.md),
            Expanded(child: AppTextField(label: 'Password Input', hintText: '••••••••', isPassword: true)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppDropdown<String>(
                label: 'Dropdown Select',
                value: _dropdownVal,
                items: const [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                  DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
                ],
                onChanged: (val) => setState(() => _dropdownVal = val),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                children: [
                  AppCheckbox(
                    label: 'Checkbox Control',
                    value: _checkboxVal,
                    onChanged: (val) => setState(() => _checkboxVal = val ?? false),
                  ),
                  AppSwitch(
                    label: 'Toggle Switch',
                    value: _switchVal,
                    onChanged: (val) => setState(() => _switchVal = val),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Section 3: Cards & Stats
        _buildSectionTitle('3. Cards & KPI Summaries'),
        const Row(
          children: [
            Expanded(
              child: AppStatCard(
                title: 'Synthetic KPI A',
                value: '128',
                subtitle: 'vs last week',
                badgeText: '+12%',
                icon: Icons.trending_up,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppStatCard(
                title: 'Synthetic KPI B',
                value: '94.2%',
                subtitle: 'Optimal range',
                badgeText: 'Stable',
                badgeColor: Color(0xFF3B82F6),
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Section 4: Avatars & Badges
        _buildSectionTitle('4. Avatars & Status Badges'),
        const Row(
          children: [
            AppAvatar(name: 'Alice Smith', size: AppAvatarSize.medium),
            SizedBox(width: AppSpacing.sm),
            AppAvatar(name: 'Bob Jones', size: AppAvatarSize.medium),
            SizedBox(width: AppSpacing.md),
            AppStatusBadge.success(label: 'Active'),
            SizedBox(width: AppSpacing.xs),
            AppStatusBadge.warning(label: 'Pending'),
            SizedBox(width: AppSpacing.xs),
            AppStatusBadge.error(label: 'Rejected'),
            SizedBox(width: AppSpacing.xs),
            AppStatusBadge.info(label: 'Informational'),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Section 5: Banners & Alerts
        _buildSectionTitle('5. Feedback & Banners'),
        const AppAlertBanner.info(
          title: 'System Information',
          message: 'This is a reusable info banner component.',
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppAlertBanner.error(
          title: 'Validation Error',
          message: 'Please review highlighted fields.',
        ),
        const SizedBox(height: AppSpacing.xl),

        // Section 6: Data Table
        _buildSectionTitle('6. Responsive Data Table'),
        AppTable(
          columns: const [
            AppTableColumn(title: 'ID', width: 80),
            AppTableColumn(title: 'Item Label'),
            AppTableColumn(title: 'Category'),
            AppTableColumn(title: 'Status', width: 120),
          ],
          rows: [
            [
              const Text('#001'),
              const Text('Synthetic Sample Alpha'),
              const Text('Category A'),
              const AppStatusBadge.success(label: 'Approved'),
            ],
            [
              const Text('#002'),
              const Text('Synthetic Sample Beta'),
              const Text('Category B'),
              const AppStatusBadge.warning(label: 'In Review'),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppPagination(currentPage: 1, totalPages: 5),
        const SizedBox(height: AppSpacing.xl),

        // Section 7: Dialogs & Overlays
        _buildSectionTitle('7. Dialogs & File Surfaces'),
        Row(
          children: [
            AppButton.secondary(
              label: 'Trigger Confirmation Dialog',
              onPressed: () {
                AppDialog.show(
                  context,
                  title: 'Sample Dialog',
                  content: 'This is a reusable confirmation dialog primitive.',
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const AppFileUploadSurface(),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(title, style: AppTypography.sectionHeading),
    );
  }
}
