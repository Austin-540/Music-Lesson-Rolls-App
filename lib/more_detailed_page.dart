import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:music_lessons_attendance/home_page.dart';
import 'globals.dart';
import 'package:intl/intl.dart';

class MoreDetailedLessonsPage extends StatefulWidget {
  const MoreDetailedLessonsPage({super.key});

  @override
  State<MoreDetailedLessonsPage> createState() =>
      _MoreDetailedLessonsPageState();
}

class _MoreDetailedLessonsPageState extends State<MoreDetailedLessonsPage> {
  Future getLessons() async {
    final lessons = await pb
        .collection('lessons')
        .getFullList(sort: '+time', expand: "students, teacher", batch: 1000);
    //tradeoff of not specifying weekday here: will take longer if you're only looking at todays lessons, but you will only need to see one loading screen if you're looking at a different days lessons
    return jsonDecode(lessons.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "More Options",
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: ListView(
        //allow scrolling
        children: [
          const Center(child: Text("One off lessons have moved to the profile picture menu on the home page")),
          FutureBuilder(
            future: getLessons(),
            initialData: null,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    ListOfLessonsWithMoreDetails(lessonsDetails: snapshot.data)
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("Error -- ${snapshot.error}");
              } else {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: CircularProgressIndicator(), //loading icon
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
  final List lessonsDetails;

  @override
  State<ListOfLessonsWithMoreDetails> createState() =>
      _ListOfLessonsWithMoreDetailsState();
}

class _ListOfLessonsWithMoreDetailsState
    extends State<ListOfLessonsWithMoreDetails> {
  String weekday = DateFormat('EEEE')
      .format(DateTime.now()); // eg "Monday", by default show current day
  @override
  Widget build(BuildContext context) {
    double paddingWidth = 8;
    if (MediaQuery.of(context).size.width > 550) {
      paddingWidth = (MediaQuery.of(context).size.width - 550) / 2;
    }

    var newListOfLessons = [];
    for (int x = 0; x <= widget.lessonsDetails.length - 1; x++) {
      if (widget.lessonsDetails[x]['weekday'] == weekday) {
        newListOfLessons.add(widget.lessonsDetails[
            x]); //only show lessons of the day currently selected
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingWidth),
      child: Column(children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "$weekday's Lessons",
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: PopupMenuButton(
                  onSelected: (item) => setState(() {
                        //refresh UI
                        weekday = item;
                      }),
                  itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "Monday",
                          child: Text("Monday"),
                        ),
                        const PopupMenuItem(
                          value: "Tuesday",
                          child: Text("Tuesday"),
                        ),
                        const PopupMenuItem(
                          value: "Wednesday",
                          child: Text("Wednesday"),
                        ),
                        const PopupMenuItem(
                          value: "Thursday",
                          child: Text("Thursday"),
                        ),
                        const PopupMenuItem(
                          value: "Friday",
                          child: Text("Friday"),
                        ),
                      ]),
            ),
          ],
        ),
        ListOfLessons(
          lessonList: newListOfLessons,
          showAll: true,
          showTeacher: true,
        ) //reuse other widget
      ]),
    );
  }
}
