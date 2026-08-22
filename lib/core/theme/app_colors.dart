import 'package:flutter/material.dart';

/// Centralized semantic color tokens for Dayflow HRMS.
abstract class AppColors {
  // Brand / Primary Palette (Indigo / Deep Slate Accent)
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color primaryActive = Color(0xFF1E40AF);
  static const Color primaryContainer = Color(0xFFEFF6FF);

  // Secondary / Neutral Palette (Slate)
  static const Color secondary = Color(0xFF475569);
  static const Color secondaryHover = Color(0xFF334155);

  // Light Mode Surfaces & Backgrounds
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevatedSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color lightDivider = Color(0xFFF1F5F9); // Slate 100

  // Light Mode Typography Colors
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600
  static const Color lightTextMuted = Color(0xFF94A3B8); // Slate 400
  static const Color lightDisabled = Color(0xFFCBD5E1); // Slate 300

  // Dark Mode Surfaces & Backgrounds
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkElevatedSurface = Color(0xFF334155); // Slate 700
  static const Color darkBorder = Color(0xFF334155); // Slate 700
  static const Color darkDivider = Color(0xFF1E293B); // Slate 800

  // Dark Mode Typography Colors
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextMuted = Color(0xFF64748B); // Slate 500
  static const Color darkDisabled = Color(0xFF475569); // Slate 600

  // Semantic Feedback Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successContainer = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningContainer = Color(0xFFFFFBEE);
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorContainer = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6); // Sky 500
  static const Color infoContainer = Color(0xFFF0F9FF);
}
