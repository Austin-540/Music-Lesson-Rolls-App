import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'color_schemes.g.dart';


void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(useMaterial3: true, brightness: Brightness.light, colorScheme: lightColorScheme),
      dark: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorScheme: darkColorScheme),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Music Lesson Rolls',
        theme: theme,
        darkTheme: darkTheme,
        home: const MyHomePage(title: "Today's Lessons",),
      ),
    );
  }
}

