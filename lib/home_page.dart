import 'dart:async';
import 'dart:convert';
import 'new_lesson_marking.dart';
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
  email, password!, // the ! will cause the try block to fail if there is no saved password, pushing to login screen
    );


    
    final authDataMap = jsonDecode(authData.toString());
    loggedInTeacher = authDataMap["record"]["id"];


          final latestVersion = await http.get(Uri.parse("https://austin-540.github.io/Database-Stuff/current_version.html"));
      if (latestVersion.body != "$version\n") {
        // ignore: use_build_context_synchronously
        showDialog(context: context, builder: (context) => AlertDialog(title: Text("Please update"), content: Text("You are using an outdated version of the website. You may need to restart your web browser for it to update.\n\nYour website version: $version\nLatest version: ${latestVersion.body}"),));

      }

      final checkForCustomError = await http.get(Uri.parse("https://austin-540.github.io/Database-Stuff/")); 
      //Allows me to set a custom error message if something breaks
      if (checkForCustomError.body == "OK\n"){
      return authDataMap; //finish the FutureBuilder
      } else {
        // ignore: use_build_context_synchronously
        showDialog(context: context, builder: (context) => AlertDialog(title: Text(checkForCustomError.body),)); //show error message
      }


    } on SocketException { //sometimes occours when PB cant be reached, but usually its ClientException
      showDialog(context: context, builder: (BuildContext context) {
        return const AlertDialog(title: Text("Internet error"),
        );
      });
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);

    } on ClientException { //Occours when PB can't be reached, or PB sends an error response
      showDialog(context: context, builder: (BuildContext context) {
        return const AlertDialog(title: Text("Internet Connection Error"),
        );
      });

    } catch (e) {
       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
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
            //loggedInTeacher check is no longer required - handled in PB permissions (keeping in case change PB permissions)
            //Date last marked is used to check wether the roll is overdue
            //eg 12 july => date_last_marked = 12_7
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
        automaticallyImplyLeading: false, //don't show a back button
        actions: [
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MoreDetailedLessonsPage())), icon: const Icon(Icons.more_horiz)),
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder:(context) => const SettingsPage())), icon: const Icon(Icons.settings)),

        ],
      ),
      body: Center(
        child: FutureBuilder( //future builder for "Welcome $name"
          future: logIn(),
          initialData: null,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: [Column(
                  children: [
                    Text("Welcome ${snapshot.data['record']['first_name']}", style: const TextStyle(fontSize: 30),),

                    FutureBuilder( // future builder for lessons
                      future: getLessons(),
                      initialData: null,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) { //once getLessons() has completed:
                          return ListOfLessons(lessonList: snapshot.data, showAll: false, showTeacher: false,);
                        } else if (snapshot.hasError) { //if getLessons() didn't work:
                          return const Text("error");
                        } else { //while waiting for getLessons():
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
    String formattedNow = "${now.hour}".padLeft(2) + "${now.minute}" .padLeft(2, "0"); //convert the time into the same format as what the DB uses

    
  if (lessonList[x]['weekday'] != DateFormat('EEEE').format(DateTime.now())) { // if looking at a lesson that isn't today
    return "...";
  } else if (lessonList[x]['date_last_marked'] == "${now.day}_${now.month}") {
      return "Completed";
    } else {
      if (int.parse(formattedNow) -10 <= int.parse(lessonList[x]["time"])){ //gives a 10 minute margin before saying overdue
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
        getLessonStatus(x) == "Upcoming" || getLessonStatus(x) == "Overdue"? //upcoming or overdue (hiding completed)
        NewLessonInList(
          details: lessonList[x], 
          status: getLessonStatus(x)
          ): const SizedBox()
      ]
    ]);

    } else {
      return Column(children: [
        for (int x=0; x<= lessonList.length-1; x++) ... [
        NewLessonInList(
          details: lessonList[x], 
          status: getLessonStatus(x)
          )

      ]
      ]);
    }} else { //if lessonList is empty, show a message
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


class LessonDetailsInList extends StatefulWidget { //no longer used, replaced by NewLessonInList
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
    } else if (int.parse(widget.time.substring(0,2)) == 12) {
      i12hrTime = "${int.parse(widget.time.substring(0,2))}:${widget.time.substring(2,4)} PM";
    }
    else {
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
                  widget.numberOfStudents == "1"? //check if the number of students is 1, and depending on that show "student(s)"
                    Text("${widget.numberOfStudents} Student"):
                    Text("${widget.numberOfStudents} Students"),

                  widget.showTeacher == false?
                    const SizedBox(): Text(widget.lessonDetails['expand']['teacher']['username']),
                  
                ],),
              ),
            )
          ],)
          
          ),
      ),
    );
  }
}


