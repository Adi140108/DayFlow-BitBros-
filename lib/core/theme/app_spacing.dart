import 'package:flutter/material.dart';

/// Centralized spacing scale for Dayflow HRMS.
abstract class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double giant = 48.0;
  static const double massive = 64.0;

  // EdgeInsets Helper Constants
  static const EdgeInsets p4 = EdgeInsets.all(xxs);
  static const EdgeInsets p8 = EdgeInsets.all(xs);
  static const EdgeInsets p12 = EdgeInsets.all(sm);
  static const EdgeInsets p16 = EdgeInsets.all(md);
  static const EdgeInsets p20 = EdgeInsets.all(lg);
  static const EdgeInsets p24 = EdgeInsets.all(xl);

  static const EdgeInsets px8 = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets px16 = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets px24 = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets py8 = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets py12 = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets py16 = EdgeInsets.symmetric(vertical: md);
}
