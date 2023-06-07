import 'dart:convert';
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
    return authData;


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
        return AlertDialog(title: Text("Wrong password/email"),
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
      print(lessonList);
      final x = jsonDecode(lessonList.toString());
      return x;
}



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
              return Column(
                children: [
                  Text(snapshot.data.toString()),
                  FutureBuilder(
                    future: getLessons(),
                    initialData: null,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return ListOfLessons(lessonList: snapshot.data);
                      } else if (snapshot.hasError) {
                        return Text("error");
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
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
  const ListOfLessons({super.key, required this.lessonList});

  @override
  Widget build(BuildContext context) {
    return Container(child: Column(children: [
      for (int x=0; x<= lessonList.length-1; x++) ... [
        LessonDetailsInList(
          instrument: lessonList[x]["instrument"], 
          time: lessonList[x]["time"], 
          lessonDetails: lessonList[x],
          numberOfStudents: lessonList[x]["students"].length.toString())
      ]
    ]),);
  }
}


class LessonDetailsInList extends StatelessWidget {
  const LessonDetailsInList({Key? key, required this.instrument, required this.time, required this.lessonDetails, required this.numberOfStudents}) : super(key: key);
  final String instrument;
  final String time;
  final Map lessonDetails;
  final String numberOfStudents;

  Future getStatusOfLesson() async {
    final now = DateTime.now();
    final formattedNow = "${now.hour}".padLeft(2) + "${now.hour}".padLeft(2);
    if (int.parse(formattedNow) <= int.parse(time)) {
      return Text("Upcoming");
    } else {
      return Text("Past");
    }
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
              child: Text("${time.substring(0,2)}:${time.substring(2,4)}" , style: TextStyle(fontSize: 35),),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                  Text(instrument),
                  FutureBuilder(
                    future: getStatusOfLesson(),
                    initialData: null,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data;
                      } else {
                        return Text("...");
                      }
                    },
                  ),
                  numberOfStudents == "1"?
                    Text(numberOfStudents + " Student"):
                    Text(numberOfStudents + " Students")
                  
                ],),
              ),
            )
          ],)
          
          ),
      ),
    );
  }
}