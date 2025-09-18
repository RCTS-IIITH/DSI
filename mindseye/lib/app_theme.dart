// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Radii
  static final cardRadius = BorderRadius.circular(14);
  static final thumbnailRadius = BorderRadius.circular(10);

  // Colors
  static Color get primaryColor => Colors.blueAccent;
  static Color get secondaryColor => Colors.deepPurple;
  static Color get surfaceColor => Colors.white;

  // Paddings
  static const horizontalPadding = 16.0;
  static const verticalPadding = 18.0;

  // Text Styles with scaling
  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20 * MediaQuery.of(context).textScaleFactor,
            ) ??
        TextStyle(
          fontSize: 20 * MediaQuery.of(context).textScaleFactor,
          fontWeight: FontWeight.bold,
        );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 15 * MediaQuery.of(context).textScaleFactor,
            ) ??
        TextStyle(fontSize: 15 * MediaQuery.of(context).textScaleFactor);
  }

  // Gradients
  static LinearGradient roleGradient(Color color) {
    return LinearGradient(
      colors: [color.withOpacity(0.95), color.withOpacity(0.6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Card Decoration
  static BoxDecoration cardDecoration(Color? color) {
    return BoxDecoration(
      color: color ?? surfaceColor,
      borderRadius: cardRadius,
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ],
    );
  }
}
