// Flutter imports:
import 'package:flutter/material.dart';
// Project imports:
import 'package:project_aether/config/assets/colors.gen.dart';

class AppTheme {
  /// LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    //! scaffold Background Color
    scaffoldBackgroundColor: AppColors.white,

    //!appbar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
    ),
  );

  /// DARK THEME
  static final ThemeData darkTheme = ThemeData(
    //! scaffold Background Color
    scaffoldBackgroundColor: AppColors.black,

    //!appbar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black,
      elevation: 0,
    ),
  );
}
