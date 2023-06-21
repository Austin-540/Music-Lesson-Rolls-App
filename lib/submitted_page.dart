import 'package:music_lessons_attendance/home_page.dart';

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
  await pb.collection('lessons').update(widget.lessonDetails['id'], body: {"date_last_marked": "${DateTime.now().day}_${DateTime.now().month}"});

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
          if (snapshot.hasData) {
            return Column(children: [
              Center(child: Icon(Icons.check, size: 250,)),
              ElevatedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyHomePage(title: "Home Page")), (route) => false), child: Text("Home Page"))
            ],);
          } else {
          return Center(child: CircularProgressIndicator(),);
          }
        },
      ),);
    
  }
}