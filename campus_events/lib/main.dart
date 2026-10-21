import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/home_shell.dart';

void main() => runApp(const MyApp());

/// The only colour literal in the project: every role of both schemes
/// is derived from it by ColorScheme.fromSeed.
const _seed = Colors.indigo;

/// Stateful because the theme mode lives here — above MaterialApp,
/// the only place that can switch between theme and darkTheme.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Events',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seed)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      routes: {
        Routes.home: (context) => HomeShell(
          themeMode: _themeMode,
          onThemeModeChanged: _setThemeMode,
        ),
      },
      onGenerateRoute: Routes.onGenerateRoute,
      onUnknownRoute: Routes.onUnknownRoute,
    );
  }
}
