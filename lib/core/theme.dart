import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4A90E2);
  static const secondary = Color(0xFF50E3C2);
  static const background = Color(0xFFF5F7FA);
  static const textDark = Color(0xFF1A1A1A);
  static const textLight = Color(0xFF9B9B9B);
}

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const body = TextStyle(
    fontSize: 16,
    color: AppColors.textDark,
  );

  static const small = TextStyle(
    fontSize: 14,
    color: AppColors.textLight,
  );
}

class AppButtons {
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}
