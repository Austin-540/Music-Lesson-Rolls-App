import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:music_lessons_attendance/home_page.dart';
import 'globals.dart';
import 'package:intl/intl.dart';


class MoreDetailedLessonsPage extends StatefulWidget {
  

  const MoreDetailedLessonsPage({super.key});

  @override
  State<MoreDetailedLessonsPage> createState() => _MoreDetailedLessonsPageState();
}

class _MoreDetailedLessonsPageState extends State<MoreDetailedLessonsPage> {
  Future getLessons() async {
    await Future.delayed(Duration(milliseconds: 200));
    final lessons = await pb.collection('lessons').getFullList(
      sort: '+time',
      expand: "teacher"
);
    print(lessons.toString());
    return jsonDecode(lessons.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("More Options",), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: ListView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
          
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Placeholder())), 
                icon: Icon(Icons.add), 
                label: Text("Mark a one-off lesson")
                ),
            ),
          ),

          FutureBuilder(
            future: getLessons(),
            initialData: null,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Column(children: [
                  ListOfLessonsWithMoreDetails(lessonsDetails: snapshot.data)
                ],);
              } else if (snapshot.hasError) {
                return Text("Error");

              } else {
                return Center(child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: CircularProgressIndicator(),
                ));
              }
            },
          ),
          
        ],
      ),
    );
  }
}

class ListOfLessonsWithMoreDetails extends StatefulWidget {
  const ListOfLessonsWithMoreDetails({super.key, required this.lessonsDetails});
  final lessonsDetails;

  @override
  State<ListOfLessonsWithMoreDetails> createState() => _ListOfLessonsWithMoreDetailsState();
}

class _ListOfLessonsWithMoreDetailsState extends State<ListOfLessonsWithMoreDetails> {
  String weekday =  DateFormat('EEEE').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    var newListOfLessons = [];
    for (int x = 0; x<= widget.lessonsDetails.length-1; x++) {
      if (widget.lessonsDetails[x]['weekday'] == weekday) {
        newListOfLessons.add(widget.lessonsDetails[x]);
      }
    }

    return Container(child: Column(children: [
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text("${weekday}'s Lessons", style: TextStyle(fontSize: 30,),),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: PopupMenuButton(
              onSelected: (item) => setState(() {
                print(item);
                weekday = item;
                print("weekday = $weekday");
          
              }),
              itemBuilder: (context) =>
              [
                PopupMenuItem(child: Text("Monday"), value: "Monday",),
                PopupMenuItem(child: Text("Tuesday"), value: "Tuesday",),
                PopupMenuItem(child: Text("Wednesday"), value: "Wednesday",),
                PopupMenuItem(child: Text("Thursday"), value: "Thursday",),
                PopupMenuItem(child: Text("Friday"), value: "Friday",),
                ]
            ),
          ),
        ],
      ), 
      ListOfLessons(lessonList: newListOfLessons, showAll: true, showTeacher: true,)
    ]),);
  }
}