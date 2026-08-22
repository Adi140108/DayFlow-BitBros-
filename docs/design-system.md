# Dayflow Design System Documentation

## Architecture
The Dayflow Design System is built natively in Flutter around semantic tokens, ensuring visual consistency across all feature modules.

## Tokens

### 1. Colors (`AppColors`)
- **Primary**: `#2563EB` (Royal Blue)
- **Secondary**: `#475569` (Slate 600)
- **Surfaces**: Light (`#FFFFFF`), Dark (`#1E293B`)
- **Backgrounds**: Light (`#F8FAFC`), Dark (`#0F172A`)
- **Borders**: Light (`#E2E8F0`), Dark (`#334155`)
- **Semantics**:
  - Success: `#10B981` (Emerald)
  - Warning: `#F59E0B` (Amber)
  - Error: `#EF4444` (Rose)
  - Info: `#3B82F6` (Sky)

### 2. Typography (`AppTypography`)
- **Display**: 32pt / Bold
- **Page Title**: 24pt / Bold
- **Section Heading**: 18pt / SemiBold
- **Body Large**: 16pt / Regular
- **Body**: 14pt / Regular
- **Body Small**: 12pt / Regular
- **Label**: 13pt / Medium
- **Caption**: 11pt / Regular
- **Button**: 14pt / SemiBold
- **Stat Emphasis**: 28pt / Bold

### 3. Spacing Scale (`AppSpacing`)
- Scale: `4, 8, 12, 16, 20, 24, 32, 40, 48, 64`

### 4. Corner Radius & Elevation (`AppRadius`)
- Radii: `sm: 4.0`, `md: 8.0`, `lg: 12.0`, `xl: 16.0`, `circular: 999.0`
- Elevation: Subtle box shadows (`shadowSm`, `shadowMd`, `shadowLg`).
