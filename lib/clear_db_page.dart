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
        sort: '-created', expand: "students, lesson.teacher.username");
    final recordsInRollsMap = jsonDecode(recordsInRolls.toString());
    var lessonDetails = [];
    for (int x = 0; x < recordsInRollsMap.length; x++) {
      lessonDetails.add(await pb
          .collection("lessons")
          .getOne(recordsInRollsMap[x]["lesson"]));
    }

    var teacherNames = [];

    for (int x = 0; x < lessonDetails.length; x++) {
      var tempdata =
          await pb.collection("users").getOne(lessonDetails[x].data['teacher']);
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
      body: ListView(children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingWidth, vertical: 10),
          child: Column(children: [
            const Card(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.info),
                  Flexible(
                      child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                        "Sometimes the backend could get clogged up. This could have been caused by someone's phone disconnecting from the internet halfway through uploading a lesson, or a glitch, or the server may have crashed while uploading a lesson. Either way, the easiest way to fix it is to delete the data and try again."),
                  )),
                ],
              ),
            )),
            FutureBuilder(
                future: getDataInDB(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data[0].isEmpty) {
                      return const Text(
                        "Nothing to show",
                        style: TextStyle(fontSize: 25),
                      );
                    } else {
                      return Column(
                        children: [
                          const Text("You are about to delete this data:"),
                          for (int x = 0; x < snapshot.data[0].length; x++) ...[
                            Card(
                              color: Theme.of(context).colorScheme.errorContainer,
                              child: Row(
                                children: [
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Student name: ${snapshot.data[0][x]["expand"]["students"]["name"].toString()}",
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        Text(
                                            "Uploaded by: ${snapshot.data[1][x].toString()}")
                                      ],
                                    ),
                                  ),
                                  const Spacer()
                                ],
                              ),
                            )
                          ],
                          ElevatedButton.icon(
                              onPressed: () => showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text("Confirm"),
                                      content: const Text(
                                          "This data cannot be recovered. This roll will need to be remarked in the more options menu. It will not reappear on the home screen."),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const DeleteStuffPage()),
                                                    (route) => false),
                                            child: const Text("I'm sure"))
                                      ],
                                    ),
                                  ),
                              icon: const Icon(Icons.delete_forever_outlined),
                              label: const Text("Delete this data"))
                        ],
                      );
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })
          ]),
        ),
      ]),
    );
  }
}

class DeleteStuffPage extends StatefulWidget {
  const DeleteStuffPage({super.key});

  @override
  State<DeleteStuffPage> createState() => _DeleteStuffPageState();
}

class _DeleteStuffPageState extends State<DeleteStuffPage> {
  bool alreadySubmitted = false;

  Future deleteStuff() async {
    if (alreadySubmitted) {
      throw "already submitted";
    } else {
      alreadySubmitted = true;
    }
    final records = await pb.collection('rolls').getFullList(
          sort: '-created',
        );

    for (int x = 0; x < records.length; x++) {
      await pb.collection('rolls').delete(records[x].id);
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deleting..."),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder(
          future: deleteStuff(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.check,
                      size: 250,
                    ),
                    ElevatedButton(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MyHomePage(title: "Today's Lessons")),
                            (route) => false),
                        child: const Text("Home Screen"))
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return const Text("O_o  Something went wrong.");
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
