import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:music_lessons_attendance/home_page.dart';
import 'globals.dart';

class ClearDBPage extends StatefulWidget {
  const ClearDBPage({super.key});

  @override
  State<ClearDBPage> createState() => _ClearDBPageState();
}

class _ClearDBPageState extends State<ClearDBPage> {

  Future<List> getDataInDB() async {
    final recordsInRolls = await pb.collection('rolls').getFullList(
  sort: '-created',
  expand: "students, lesson.teacher.username"
);
    final recordsInRollsMap = jsonDecode(recordsInRolls.toString());
    var lessonDetails = [];
    for (int x=0; x< recordsInRollsMap.length; x++) {
      lessonDetails.add(await pb.collection("lessons").getOne(recordsInRollsMap[x]["lesson"]));
    }

    var teacherNames = [];

    for (int x=0; x<lessonDetails.length; x++) {
      var tempdata = await pb.collection("users").getOne(lessonDetails[x].data['teacher']);
      teacherNames.add(tempdata.data['username']);
    }
    return [recordsInRollsMap, teacherNames];
  }
  @override
  Widget build(BuildContext context) {
    double paddingWidth = 8;
    if (MediaQuery.of(context).size.width > 550) {
      paddingWidth = (MediaQuery.of(context).size.width - 550) / 2;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clear the DB"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingWidth, vertical: 10),
          child: Column(children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.info),
                    Flexible(child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text("Sometimes the backend could get clogged up. This could have been caused by someone's phone disconnecting from the internet halfway through uploading a lesson, or a glitch, or the server may have crashed while uploading a lesson. Either way, the easiest way to fix it is to delete the data and try again."),
                    )),
                  ],
                ),
              )),
              FutureBuilder(future: getDataInDB(), 
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData){
        
                
                if (snapshot.data[0].isEmpty) {
                  return Text("Nothing to show", style: TextStyle(fontSize: 25),);
                } else {
        
                
                return Column(
                  children: [
                    Text("You are about to delete this data:"),
                    for (int x=0; x< snapshot.data[0].length; x++) ... [
                    Card(
                      color: Color.fromARGB(255, 251, 142, 142),
                      child: Row(
                      children: [
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text("Student name: ${snapshot.data[0][x]["expand"]["students"]["name"].toString()}", 
                              style: TextStyle(fontSize: 20),),
                              Text("Uploaded by: ${snapshot.data[1][x].toString()}")
                            ],
                            
                          ),
                        ),
                        Spacer()
                      ],
                    ),)
                    ],
                    ElevatedButton.icon(onPressed: () =>
                    showDialog(context: context, builder:  (BuildContext context) => AlertDialog(
                      title: Text("Confirm"),
                      content: Text("This data cannot be recovered. This roll will need to be remarked in the more options menu. It will not reappear on the home screen."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel"),),
                        TextButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> DeleteStuffPage()), (route) => false), child: Text("I'm sure"))
                      ],
                    ),)
                    , icon: Icon(Icons.delete_forever_outlined), label: Text("Delete this data"))
                  ],
                );
              }} else {
                return Center(child: CircularProgressIndicator());
              }} )
          ]),
        ),]
      ),
    );
  }
}

class DeleteStuffPage extends StatefulWidget {
  const DeleteStuffPage({super.key});

  @override
  State<DeleteStuffPage> createState() => _DeleteStuffPageState();
}

class _DeleteStuffPageState extends State<DeleteStuffPage> {
  Future deleteStuff() async {
    final records = await pb.collection('rolls').getFullList(
  sort: '-created',
);
  print(records);

  for (int x=0; x<records.length; x++) {
    await pb.collection('rolls').delete(records[x].id);
  }
  return "";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Deleting..."), backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: FutureBuilder(future: deleteStuff(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
        return Center(
          child: Column(children: [
            Icon(Icons.check, size: 250,),
            ElevatedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyHomePage(title: "Today's Lessons")), (route) => false), child: Text("Home Screen"))
          ],),
        );} else if (snapshot.hasError) {
          return Text("O_o  Something went wrong.");
        } else {
          return Center(child: CircularProgressIndicator());
        }
        } 
      ),
    );
  }
}