import 'package:music_lessons_attendance/home_page.dart';

import 'globals.dart';
import 'package:flutter/material.dart';

class SubmittedPage extends StatefulWidget {
  //used when submitting a regular lesson (not one off)
  const SubmittedPage(
      {super.key, required this.lessonDetails, required this.statuses});
  final Map lessonDetails;
  final List statuses;

  @override
  State<SubmittedPage> createState() => _SubmittedPageState();
}

class _SubmittedPageState extends State<SubmittedPage> {
  Future submitRoll() async {
    final currentlyInDb =
        await pb.collection("rolls").getFullList(sort: '-created');
    if (currentlyInDb.isNotEmpty) {
      throw "Things currently in DB";
    }

    for (int x = 0; x < widget.lessonDetails['students'].length; x++) {
      bool? finalVar;
      if (x != widget.lessonDetails['students'].length - 1) {
        //is this the final student?
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
      await pb.collection('lessons').update(widget.lessonDetails['id'], body: {
        "date_last_marked": "${DateTime.now().day}_${DateTime.now().month}"
      }); //submit that student to PB
    }
    await pb.collection('send_email_ready').create(body: {"empty": "_"});

    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submitting"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder(
        //wait until roll is finished submitting before showing tick
        future: submitRoll(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                const Center(
                    child: Icon(
                  Icons.check,
                  size: 250,
                )),
                ElevatedButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MyHomePage(title: "Home Page")),
                        (route) => false),
                    child: const Text("Home Page"))
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                children: [
                  Text(
                      "Something went wrong. \nMost likely you tried to mark a roll at the same time as someone else, or tried to mark 2 rolls in too short an amount of time. Please try again in 20ish seconds."),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MyHomePage(title: "Today's Lessons")),
                          (route) => false,
                        );
                      },
                      child: Text("Go Back"))
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
