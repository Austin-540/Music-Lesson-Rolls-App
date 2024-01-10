import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:adaptive_theme/adaptive_theme.dart';



void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(useMaterial3: true, brightness: Brightness.light, colorSchemeSeed: const Color.fromARGB(255, 134, 193, 234)),
      dark: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: const Color.fromARGB(255, 64, 134, 255)),
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

