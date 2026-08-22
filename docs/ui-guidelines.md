# Dayflow UI Guidelines

## Principles
1. **Calm & Professional**: Optimize for data readability and task efficiency. Avoid unnecessary decoration.
2. **Semantic Usage**: Always use `AppColors`, `AppTypography`, and `AppSpacing` tokens. Never hardcode hex colors or arbitrary font sizes.
3. **No Direct Business Logic in Components**: UI primitives accept typed parameters and callbacks only.

## Component Selection Guidelines
- Use `AppButton` for all user actions.
- Use `AppTextField` for text inputs.
- Use `AppStatusBadge` for status displays (Active, Pending, Rejected).
- Use `AppCard` and `AppStatCard` for information hierarchy and KPI summaries.
