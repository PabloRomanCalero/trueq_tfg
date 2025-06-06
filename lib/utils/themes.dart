import 'package:flutter/material.dart';
import 'package:trueq/utils/constants/text_theme.dart';

ThemeData CustomTheme(bool isDark) {
  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    fontFamily: "WinkySans",
    textTheme: isDark ? TextThemeTrueq.darkTextTheme() : TextThemeTrueq.lightTextTheme(),
  );
}
