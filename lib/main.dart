import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {//the root widget of the app
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Lesson Attendance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 134, 193,
                234)), //"Oxford Blue" according to the communications part of adminitstration
        useMaterial3: true, //Makes the app look more modern
      ),
      home: const MyHomePage(title: 'Today\'s Lessons'),
    );
  }
}




