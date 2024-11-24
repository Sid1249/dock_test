import 'package:flutter/material.dart';
import 'package:mac_docker_test/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'screens/dock_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: themeProvider.themeData,
          home: DockScreen(),
        );
      },
    );
  }
}