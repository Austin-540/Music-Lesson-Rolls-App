import 'globals.dart';
import 'package:flutter/material.dart';

class MarkingRollPage extends StatefulWidget {
  final String lessonID;
  const MarkingRollPage({super.key, required this.lessonID});

  @override
  State<MarkingRollPage> createState() => _MarkingRollPageState();
}

class _MarkingRollPageState extends State<MarkingRollPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Marking Roll"),
        ),
      body: Column(children: [
        Placeholder()
      ]),
    );
  }
}
