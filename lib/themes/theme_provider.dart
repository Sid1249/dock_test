import 'package:flutter/material.dart';
import 'dock_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = darkTheme;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkTheme;

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      background: Colors.white,
    ),
    extensions: <ThemeExtension<dynamic>>[
      DockTheme.light,
    ],
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1E1E1E),
    colorScheme: ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      background: Color(0xFF1E1E1E),
    ),
    extensions: <ThemeExtension<dynamic>>[
      DockTheme.dark,
    ],
  );

  void toggleTheme() {
    _themeData = _themeData == darkTheme ? lightTheme : darkTheme;
    notifyListeners();
  }
}