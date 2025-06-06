import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trueq/utils/constants/colors.dart';

class TextThemeTrueq {
  TextThemeTrueq._(); // Para evitar instancias

  static TextTheme lightTextTheme() {
    return TextTheme(
      headlineLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: ColorsTrueq.dark),
      headlineMedium: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600, color: ColorsTrueq.dark),
      headlineSmall: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: ColorsTrueq.dark),

      titleLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: ColorsTrueq.dark),
      titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: ColorsTrueq.dark),
      titleSmall: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: ColorsTrueq.dark),

      bodyLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorsTrueq.dark),
      bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal, color: ColorsTrueq.dark),
      bodySmall: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorsTrueq.dark.withAlpha((0.5 * 255).toInt())),

      labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal, color: ColorsTrueq.dark),
      labelMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal, color: ColorsTrueq.dark.withAlpha((0.5 * 255).toInt())),
    );
  }

  static TextTheme darkTextTheme() {
    return TextTheme(
      headlineLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: ColorsTrueq.light),
      headlineMedium: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600, color: ColorsTrueq.light),
      headlineSmall: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: ColorsTrueq.light),

      titleLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: ColorsTrueq.light),
      titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: ColorsTrueq.light),
      titleSmall: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: ColorsTrueq.light),

      bodyLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorsTrueq.light),
      bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal, color: ColorsTrueq.light),
      bodySmall: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorsTrueq.light.withAlpha((0.5 * 255).toInt())),

      labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal, color: ColorsTrueq.light),
      labelMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal, color: ColorsTrueq.light.withAlpha((0.5 * 255).toInt())),
    );
  }
}
