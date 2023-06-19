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
      for (int x=0; x< widget.presentStudents.length; x++) {
    bool? finalVar;
  if (x != widget.presentStudents.length-1) {
  finalVar = false;
  } else {
  finalVar = true;
  }
  
  final body = <String, dynamic>{
  "students": widget.presentStudents[x]['id'],
  "lesson": widget.lessonDetails['id'],
  "present": true,
  "final": finalVar
};
  await pb.collection('rolls').create(body: body);
  }


    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submitting"), backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: FutureBuilder(
        future: submitRoll(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Text("hello world");
        },
      ),);
    
  }
}