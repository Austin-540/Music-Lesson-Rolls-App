import 'dart:async';
import 'dart:convert';

import 'dart:io';

import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:music_lessons_attendance/marking_the_roll_page.dart';
import 'globals.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'settings_page.dart';
import 'login_page.dart';
import 'package:pocketbase/pocketbase.dart';

import 'more_detailed_page.dart';
import 'package:http/http.dart' as http;


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

Future logIn() async {

    try {
    const storage = FlutterSecureStorage();
    String? email = await storage.read(key: "email");
    String? password = await storage.read(key: "password");

    if (email == null) {
      throw "no saved data";
    }

    final authData = await pb.collection('users').authWithPassword(
  email, password!,
    );


    
    final x = jsonDecode(authData.toString());
    loggedInTeacher = x["record"]["id"];

      final y = await http.get(Uri.parse("https://austin-540.github.io/Database-Stuff/"));
      if (y.body == "OK\n"){
      return x;
      } else {
        showDialog(context: context, builder: (context) => AlertDialog(title: Text(y.body),));
      }


    } on SocketException {
      showDialog(context: context, builder: (BuildContext context) {
        return const AlertDialog(title: Text("Internet error"),
        );
      });
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);

    } on ClientException {
      showDialog(context: context, builder: (BuildContext context) {
        return const AlertDialog(title: Text("Internet Connection Error"),
        );
      });

    } catch (e) {
       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
    }
    //first try to see if password is already saved, then if its not push to login screen

  }

Future getLessons() async {
  final lessonList = await pb.collection('lessons').getFullList(
      sort: '+time',
      expand: "students,teacher",
      filter: "weekday = '${DateFormat('EEEE').format(DateTime.now())}'"
      );
      // print(lessonList);
      final x = jsonDecode(lessonList.toString());

      var y = [];
      
        for (int i = 0; i<= x.length-1; i++) {
          if (loggedInTeacher == x[i]['teacher'] && x[i]['date_last_marked'] != "${DateTime.now().day}_${DateTime.now().month}") {
            y.add(x[i]);
          }
          
        
      }
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
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MoreDetailedLessonsPage())), icon: const Icon(Icons.more_horiz)),
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder:(context) => const SettingsPage())), icon: const Icon(Icons.settings)),

        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: logIn(),
          initialData: null,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: [Column(
                  children: [
                    Text("Welcome ${snapshot.data['record']['first_name']}", style: const TextStyle(fontSize: 30),),

                    FutureBuilder(
                      future: getLessons(),
                      initialData: null,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return ListOfLessons(lessonList: snapshot.data, showAll: false, showTeacher: false,);
                        } else if (snapshot.hasError) {
                          return const Text("error");
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ],
                ),]
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
    ));
  }
}


class ListOfLessons extends StatelessWidget {
  final bool showTeacher;
  final List lessonList;
  final bool showAll;
  const ListOfLessons({super.key, required this.lessonList, required this.showAll, required this.showTeacher});

  String getLessonStatus(x) {
    DateTime now = DateTime.now();
    String formattedNow = "${now.hour}".padLeft(2) + "${now.minute}" .padLeft(2, "0");

    

  if (lessonList[x]['date_last_marked'] == "${now.day}_${now.month}") {
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
    if (lessonList.isNotEmpty) {
    if (showAll == false) {
    return Column(children: [
      for (int x=0; x<= lessonList.length-1; x++) ... [
        getLessonStatus(x) == "Upcoming" || getLessonStatus(x) == "Overdue"?
        LessonDetailsInList(
          instrument: lessonList[x]["instrument"], 
          time: lessonList[x]["time"], 
          lessonDetails: lessonList[x],
          numberOfStudents: lessonList[x]["students"].length.toString(),
          status: getLessonStatus(x),
          showTeacher: false,
          ): const SizedBox()
      ]
    ]);

    } else {
      return Column(children: [
        for (int x=0; x<= lessonList.length-1; x++) ... [
        LessonDetailsInList(
          instrument: lessonList[x]["instrument"], 
          time: lessonList[x]["time"], 
          lessonDetails: lessonList[x],
          numberOfStudents: lessonList[x]["students"].length.toString(),
          status: getLessonStatus(x),
          showTeacher: showTeacher,
          )

      ]
      ]);
    }} else {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Card(child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Text("Looks like there's nothing to show", style: TextStyle(fontSize: 15),),
        ),),
      );
    }
  }
}


class LessonDetailsInList extends StatefulWidget {
  const LessonDetailsInList({Key? key, required this.instrument, required this.time, required this.lessonDetails, required this.numberOfStudents, required this.status, required this.showTeacher}) : super(key: key);
  final String instrument;
  final String time;
  final Map lessonDetails;
  final String numberOfStudents;
  final String status;
  final bool showTeacher;



  @override
  State<LessonDetailsInList> createState() => _LessonDetailsInListState();
}

class _LessonDetailsInListState extends State<LessonDetailsInList> {


  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 20), (Timer t) => setState((){}));
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
    
  }

  @override
  Widget build(BuildContext context) {
      String? i12hrTime;
  if (int.parse(widget.time.substring(0,2)) > 12) {
      i12hrTime = "${int.parse(widget.time.substring(0,2))-12}:${widget.time.substring(2,4)} PM";
    } else {
      i12hrTime = "${widget.time.substring(0,2)}:${widget.time.substring(2,4)} AM";
    }
    Color? colour;
    
    if (widget.status == "Upcoming"){
      colour = const Color.fromARGB(255, 255, 255, 255);
    } else if (widget.status == "Overdue") {
      colour = const Color.fromARGB(255, 252, 199, 199);
    } else if (widget.status == "Completed") {
      colour = const Color.fromARGB(255, 213, 255, 220);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MarkingRollPage(lessonDetails: widget.lessonDetails))); 
        },
        child: Card(
          color: colour,
          
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Row(
            children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(i12hrTime , style: const TextStyle(fontSize: 35),),
            ),
            const Spacer(),
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
                    Text("${widget.numberOfStudents} Student"):
                    Text("${widget.numberOfStudents} Students"),

                  widget.showTeacher == false?
                    SizedBox(): Text(widget.lessonDetails['expand']['teacher']['username']),
                  
                ],),
              ),
            )
          ],)
          
          ),
      ),
    );
  }
}


