import 'package:flutter/material.dart';

class OneOffLessonPage extends StatefulWidget {
  const OneOffLessonPage({super.key});

  @override
  State<OneOffLessonPage> createState() => _OneOffLessonPageState();
}

class _OneOffLessonPageState extends State<OneOffLessonPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("One-off Lesson")),
      body: Column(children: [
        Text("Hello world")
      ]),
    );
  }
}