import 'package:music_lessons_attendance/home_page.dart';

import 'globals.dart';
import 'package:flutter/material.dart';

class SubmittedPage extends StatefulWidget { //used when submitting a regular lesson (not one off)
  const SubmittedPage({super.key, required this.lessonDetails, required this.statuses});
  final lessonDetails;
  final statuses;

  @override
  State<SubmittedPage> createState() => _SubmittedPageState();
}

class _SubmittedPageState extends State<SubmittedPage> {
  Future submitRoll() async {
      for (int x=0; x< widget.lessonDetails['students'].length; x++) {
    bool? finalVar;
  if (x != widget.lessonDetails['students'].length-1) { //is this the final student?
  finalVar = false;
  } else {
  finalVar = true;
  }
  
  final body = <String, dynamic>{
  "students": widget.lessonDetails['students'][x],
  "lesson": widget.lessonDetails['id'],
  "present": widget.statuses[x],
  "final": finalVar
};
  await pb.collection('rolls').create(body: body);
  await pb.collection('lessons').update(widget.lessonDetails['id'], body: {"date_last_marked": "${DateTime.now().day}_${DateTime.now().month}"}); //submit that student to PB

  }


    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submitting"), backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: FutureBuilder( //wait until roll is finished submitting before showing tick
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