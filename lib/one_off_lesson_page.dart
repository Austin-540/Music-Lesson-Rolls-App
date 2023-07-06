import 'package:flutter/material.dart';
import 'package:music_lessons_attendance/submitted_page.dart';
import 'globals.dart';
import 'home_page.dart';

class OneOffLessonPage extends StatefulWidget {
  const OneOffLessonPage({super.key});

  @override
  State<OneOffLessonPage> createState() => _OneOffLessonPageState();
}

class _OneOffLessonPageState extends State<OneOffLessonPage> {
  var time = "Pick lesson time";
  var listOfStudents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("One-off Lesson"), backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: Column(children: [
        Center(child: Text(time, style: TextStyle(fontSize: 40),)),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(label: Text("Select Time"), icon: Icon(Icons.access_time), 
          onPressed: () async {
           final timeOfDay = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            setState(() {
              time = "${timeOfDay!.hour}:${timeOfDay.minute}";
            });
            })
        ),

        for (int x=0; x<listOfStudents.length; x++) ... [
          Card(child: Row(
            children: [
              Spacer(),
              Text(listOfStudents[x], style: TextStyle(fontSize: 25),),
              Spacer(),
              IconButton(onPressed: () => setState(() {
                listOfStudents.removeAt(x);
              }), icon: Icon(Icons.delete))
            ],
          ),)
        ],

        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextField(
            controller: TextEditingController(),
            onSubmitted: (value) => setState(() {
              listOfStudents.add(value);
            }),),
        ),

        ElevatedButton(onPressed:() => Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => OneOffLessonSubmitPage(listOfStudents: listOfStudents,)), 
        (route) => false), child: Text("Submit Lesson"))

        
      ]),
    );
  }
}

class OneOffLessonSubmitPage extends StatefulWidget {
  final listOfStudents;
  const OneOffLessonSubmitPage({super.key, required this.listOfStudents});

  @override
  State<OneOffLessonSubmitPage> createState() => _OneOffLessonSubmitPageState();
}

class _OneOffLessonSubmitPageState extends State<OneOffLessonSubmitPage> {
  Future submitRoll() async {
      for (int x=0; x<= widget.listOfStudents.length; x++) {
    bool? finalVar;
  if (x != widget.listOfStudents.length-1) {
  finalVar = false;
  } else {
  finalVar = true;
  }
  
  final body = <String, dynamic>{
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
      appBar: AppBar(title: Text("Submitting..."), backgroundColor: Theme.of(context).colorScheme.inversePrimary,),

      body: FutureBuilder(
        future: submitRoll(),
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Column(children: [
              Center(child: Icon(Icons.check, size: 250,)),
              ElevatedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyHomePage(title: "Home Page")), (route) => false), child: Text("Home Page"))
            ],);
          } else if (snapshot.hasError) {
            return Text("error");
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}