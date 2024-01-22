import 'package:flutter/material.dart';
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
  bool showTimeError = false;
  bool showEmptyListError = false;
  final textEditingController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    double paddingWidth = 15;
    if (MediaQuery.of(context).size.width > 550) {
      paddingWidth = (MediaQuery.of(context).size.width - 550) / 2;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("One-off Lesson"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(children: [
        Center(
            child: Text(
          time,
          style: const TextStyle(fontSize: 40),
        )),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
                label: const Text("Select Time"),
                icon: const Icon(Icons.access_time),
                onPressed: () async {
                  final timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (timeOfDay != null) {
                    //if it is null keep it as "Pick lesson time"
                    setState(() {
                      time =
                          "${timeOfDay.hour}:${timeOfDay.minute.toString().padLeft(2, '0')}"; //convert to string
                    });
                  }
                })),
        for (int x = 0; x < listOfStudents.length; x++) ...[
          //For each student have a card with their name and a button to remove them
          Card(
            child: Row(
              children: [
                const Spacer(),
                Text(
                  listOfStudents[x],
                  style: const TextStyle(fontSize: 25),
                ),
                const Spacer(),
                IconButton(
                    onPressed: () => setState(() {
                          listOfStudents.removeAt(x);
                        }),
                    icon: const Icon(Icons.delete))
              ],
            ),
          )
        ],
        Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingWidth, vertical: 15),
          child: TextField(
            decoration: const InputDecoration(hintText: "Student's Name"),
            controller: textEditingController,
            onEditingComplete: () {},
            onSubmitted: (value) => setState(() {
              //when enter is pressed, add the student to the list
              if (value != "") {
                //only if they wrote something
                listOfStudents.add(value);
                textEditingController.clear();
              }
            }),
          ),
        ),
        ElevatedButton(
            onPressed: () {
              if (time != "Pick lesson time" && listOfStudents.isNotEmpty) {
                //if both bits of info have been entered
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OneOffLessonSubmitPage(
                            listOfStudents: listOfStudents, time: time)),
                    (route) => false);
              } else if (time == "Pick lesson time") {
                setState(() {
                  showTimeError = true;
                });
              } else if (listOfStudents.isEmpty) {
                setState(() {
                  showEmptyListError = true;
                });
              }
            },
            child: const Text("Submit Lesson")),
        showTimeError
            ? const Text("You need to select a time before submitting.",
                style: TextStyle(color: Colors.red))
            : const SizedBox(),
        showEmptyListError
            ? const Text(
                "Press enter after typing each name.",
                style: TextStyle(color: Colors.red),
              )
            : const SizedBox(),
      ]),
    );
  }
}

class OneOffLessonSubmitPage extends StatefulWidget {
  final List listOfStudents;
  final String time;
  const OneOffLessonSubmitPage(
      {super.key, required this.listOfStudents, required this.time});

  @override
  State<OneOffLessonSubmitPage> createState() => _OneOffLessonSubmitPageState();
}

class _OneOffLessonSubmitPageState extends State<OneOffLessonSubmitPage> {
  var alreadySubmitted = false;
  
  Future submitRoll() async {
    if (alreadySubmitted == true) {
    throw "Already submitted";
  } else {
    alreadySubmitted = true;
  }
    for (int x = 0; x <= widget.listOfStudents.length - 1; x++) {
      bool? finalVar;
      if (x != widget.listOfStudents.length - 1) {
        finalVar = false;
      } else {
        finalVar = true;
      }

      final body = <String, dynamic>{
        "final": finalVar,
        "student_name": widget.listOfStudents[x],
        "time": widget.time,
      };
      await pb
          .collection('one_off_rolls')
          .create(body: body); //create a record with each students' info
    }
    return "Success"; //finish FutureBuilder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submitting..."),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder(
        future: submitRoll(),
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                const Center(
                    child: Icon(
                  Icons.check,
                  size: 250,
                )), //show a very big tick icon
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
            return const Text("error");
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
