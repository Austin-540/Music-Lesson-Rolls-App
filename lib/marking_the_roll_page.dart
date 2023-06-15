import 'globals.dart';
import 'package:flutter/material.dart';

class MarkingRollPage extends StatefulWidget {
  final Map lessonDetails;
  const MarkingRollPage({super.key, required this.lessonDetails});

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
        Text(widget.lessonDetails.toString()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text("${widget.lessonDetails['time']}", style: TextStyle(fontSize: 50),),
              Spacer(),
              Text("${widget.lessonDetails['instrument']}",style: TextStyle(fontSize: 30)),
            ],
          ),
        ),
        for (int x = 0; x< widget.lessonDetails['expand']['students'].length; x++) ... [
        StudentInLesson(),
        ]
      ]),
    );
  }
}

class StudentInLesson extends StatefulWidget {
  const StudentInLesson({super.key});

  @override
  State<StudentInLesson> createState() => _StudentInLessonState();
}

class _StudentInLessonState extends State<StudentInLesson> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Row(children: [
          Text("Name goes here"),
          Spacer(),
          Checkbox(value: isChecked, onChanged: (value) => setState(() {
            isChecked = value!;
          }) )
        ],),
      ),
    );
  }
}