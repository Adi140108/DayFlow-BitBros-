import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

class AppTableColumn {
  final String title;
  final double? width;
  final FlexColumnWidth? flex;

  const AppTableColumn({
    required this.title,
    this.width,
    this.flex,
  });
}

/// Responsive Data Table component for Dayflow HR dense datasets.
class AppTable extends StatelessWidget {
  final List<AppTableColumn> columns;
  final List<List<Widget>> rows;
  final bool isLoading;

  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                topRight: Radius.circular(AppRadius.md),
              ),
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: columns.map((col) {
                final child = Text(
                  col.title,
                  style: AppTypography.label.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                );
                if (col.width != null) {
                  return SizedBox(width: col.width, child: child);
                }
                return Expanded(child: child);
              }).toList(),
            ),
          ),
          // Table Rows
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: CircularProgressIndicator(),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Text(
                'No records found.',
                style: AppTypography.body.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: borderColor),
              itemBuilder: (context, rowIndex) {
                final cells = rows[rowIndex];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: List.generate(columns.length, (colIndex) {
                      final cell = colIndex < cells.length ? cells[colIndex] : const SizedBox();
                      final col = columns[colIndex];
                      if (col.width != null) {
                        return SizedBox(width: col.width, child: cell);
                      }
                      return Expanded(child: cell);
                    }),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Pagination controller toolbar.
class AppPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;

  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Page $currentPage of $totalPages',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Row(
          children: [
            AppButton.secondary(
              label: 'Previous',
              size: AppButtonSize.small,
              onPressed: currentPage > 1 && onPageChanged != null
                  ? () => onPageChanged!(currentPage - 1)
                  : null,
            ),
            const SizedBox(width: AppSpacing.xs),
            AppButton.secondary(
              label: 'Next',
              size: AppButtonSize.small,
              onPressed: currentPage < totalPages && onPageChanged != null
                  ? () => onPageChanged!(currentPage + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
