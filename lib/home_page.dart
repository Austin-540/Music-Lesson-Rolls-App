import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'globals.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'settings_page.dart';
import 'login_page.dart';
import 'package:pocketbase/pocketbase.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showAll = false;

Future logIn() async {
    Future.delayed(Duration(milliseconds: 500));

  String? email;
  String? password;
  RecordAuth? authData;

    try {
    final storage = new FlutterSecureStorage();
    String? email = await storage.read(key: "email");
    String? password = await storage.read(key: "password");

    if (email == null) {
      throw "no saved data";
    }

    final authData = await pb.collection('users').authWithPassword(
  email!, password!,
    );
    print(authData);


    
    final x = jsonDecode(authData.toString());
    loggedInTeacher = x["record"]["id"];
    
    return x;


    } on SocketException {
      print("SocketException");
      showDialog(context: context, builder: (BuildContext context) {
        print("Internet error");
        return AlertDialog(title: Text("Internet error"),
        );
      });
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);

    } on ClientException {
      showDialog(context: context, builder: (BuildContext context) {
        return AlertDialog(title: Text("Internet Connection Error"),
        );
      });

    } catch (e) {
      print("Caught $e");
       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
    }
    //first try to see if password is already saved, then if its not push to login screen

  }

Future getLessons() async {
  final lessonList = await pb.collection('lessons').getFullList(
      sort: '+time',
      expand: "students"
      );
      // print(lessonList);
      final x = jsonDecode(lessonList.toString());

      var y = [];
      
        for (int i = 0; i<= x.length-1; i++) {
          if (showAll == false) {
          if (loggedInTeacher == x[i]['teacher']) {
            y.add(x[i]);
          }
        
      } else {
        y.add(x[i]);
      }}
      return y;
}

  String? loggedInTeacher;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder:(context) => SettingsPage())), icon: Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: logIn(),
          initialData: null,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Text("Welcome ${snapshot.data['record']['first_name']}", style: TextStyle(fontSize: 30),),
                    showAll == false?
                    Column(
                      children: [
                        Text("Only Showing Today's Lessons Overdue/Upcoming You Teach", style: TextStyle(fontSize: 12),),
                        ElevatedButton(onPressed: () => setState(() {
                          showAll = true;
                        }), child: Text("Show All"))
                      ]
                    ): ElevatedButton(onPressed: () => setState(() {
                      showAll = false;
                    }), child: Text("Filter Lessons")),
                    FutureBuilder(
                      future: getLessons(),
                      initialData: null,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        print(snapshot.data);
                        if (snapshot.hasData) {
                          return ListOfLessons(lessonList: snapshot.data, showAll: showAll,);
                        } else if (snapshot.hasError) {
                          return Text("error");
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ],
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
    ));
  }
}


class ListOfLessons extends StatelessWidget {
  final lessonList;
  final showAll;
  const ListOfLessons({super.key, required this.lessonList, required this.showAll});

  String getLessonStatus(x) {
    DateTime now = new DateTime.now();
    String formattedNow = "${now.hour}".padLeft(2) + "${now.minute}" .padLeft(2, "0");

    if (lessonList[x]['date_last_marked'] == "${now.day}") {
      return "Completed";
    } else {
      if (int.parse(formattedNow) <= int.parse(lessonList[x]["time"])){
      return "Upcoming";
    } else {
      return "Overdue";
    }}
  }

  @override
  Widget build(BuildContext context) {
    print(showAll.toString() + "- 151");
    if (showAll == false) {
    return Container(child: Column(children: [
      for (int x=0; x<= lessonList.length-1; x++) ... [
        getLessonStatus(x) == "Upcoming" || getLessonStatus(x) == "Overdue"?
        LessonDetailsInList(
          instrument: lessonList[x]["instrument"], 
          time: lessonList[x]["time"], 
          lessonDetails: lessonList[x],
          numberOfStudents: lessonList[x]["students"].length.toString(),
          status: getLessonStatus(x),
          ): SizedBox()
      ]
    ]),);

    } else {
      return Container(child: Column(children: [
        for (int x=0; x<= lessonList.length-1; x++) ... [
        LessonDetailsInList(
          instrument: lessonList[x]["instrument"], 
          time: lessonList[x]["time"], 
          lessonDetails: lessonList[x],
          numberOfStudents: lessonList[x]["students"].length.toString(),
          status: getLessonStatus(x),
          )

      ]
      ]),);
    }
  }
}


class LessonDetailsInList extends StatefulWidget {
  const LessonDetailsInList({Key? key, required this.instrument, required this.time, required this.lessonDetails, required this.numberOfStudents, required this.status}) : super(key: key);
  final String instrument;
  final String time;
  final Map lessonDetails;
  final String numberOfStudents;
  final String status;


  @override
  State<LessonDetailsInList> createState() => _LessonDetailsInListState();
}

class _LessonDetailsInListState extends State<LessonDetailsInList> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 20), (Timer t) => setState((){print("Refresh");}));
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
    
  }

  @override
  Widget build(BuildContext context) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Placeholder())); 
        },
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Row(
            children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text("${widget.time.substring(0,2)}:${widget.time.substring(2,4)}" , style: TextStyle(fontSize: 35),),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                  Text(widget.instrument),
                  Text(widget.status),
                  widget.numberOfStudents == "1"?
                    Text(widget.numberOfStudents + " Student"):
                    Text(widget.numberOfStudents + " Students")
                  
                ],),
              ),
            )
          ],)
          
          ),
      ),
    );
  }
}