import 'globals.dart';
import 'package:flutter/material.dart';

class SubmittedPage extends StatefulWidget {
  const SubmittedPage({super.key, required this.lessonDetails, required this.presentStudents});
  final lessonDetails;
  final presentStudents;

  @override
  State<SubmittedPage> createState() => _SubmittedPageState();
}

class _SubmittedPageState extends State<SubmittedPage> {
  Future submitRoll() async {
    final body = <String, dynamic>{
  "students": widget.presentStudents[0]['id'],
  "lesson": widget.lessonDetails['id'],
  "present": true,
  "final": false
};

    await pb.collection('rolls').create(body: body);

    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submitting"), backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: FutureBuilder(
        future: submitRoll(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Text("m");
        },
      ),);
    
  }
}