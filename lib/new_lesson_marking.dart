// ignore_for_file: prefer_const_constructors

import 'package:intl/intl.dart';
import 'package:music_lessons_attendance/submitted_page.dart';
import 'package:flutter/material.dart';

class NewLessonInList extends StatefulWidget {
  final Map details;
  final String status;
  const NewLessonInList(
      {super.key, required this.details, required this.status});

  @override
  State<NewLessonInList> createState() => _NewLessonInListState();
}

class _NewLessonInListState extends State<NewLessonInList> {
  List _rollOptions = [];

  @override
  void initState() {
    super.initState();
    _rollOptions =
        List.filled(20, "none"); //makes max number of students in a lesson 20
  }

  @override
  Widget build(BuildContext context) {
    String i12hrTime;

    //convert computer readable time into 12hr time for humans
    if (int.parse(widget.details['time'].substring(0, 2)) > 12) {
      i12hrTime =
          "${int.parse(widget.details['time'].substring(0, 2)) - 12}:${widget.details['time'].substring(2, 4)} PM";
    } else if (int.parse(widget.details['time'].substring(0, 2)) == 12) {
      i12hrTime =
          "${int.parse(widget.details['time'].substring(0, 2))}:${widget.details['time'].substring(2, 4)} PM";
    } else {
      i12hrTime =
          "${widget.details['time'].substring(0, 2)}:${widget.details['time'].substring(2, 4)} AM";
    }

//get colour for the Card to be

    Future getCardColour() async {
Color? statusColour;
    bool activeStatus;
    if (Theme.of(context).brightness == Brightness.light) {
    if (widget.details['weekday'] ==
        DateFormat('EEEE').format(DateTime.now())) {
      activeStatus = true;
      if (widget.status == "Completed") {
        statusColour = const Color.fromARGB(255, 214, 252, 205);
      } else if (widget.status == "Overdue") {
        statusColour = const Color.fromARGB(255, 255, 182, 182);
      } else {
        statusColour = null; //uses default colour
      }
    } else {
      activeStatus = false;
    }} else {
      if (widget.details['weekday'] ==
        DateFormat('EEEE').format(DateTime.now())) {
      activeStatus = true;
      if (widget.status == "Completed") {
        statusColour = const Color.fromARGB(255, 9, 48, 0);
      } else if (widget.status == "Overdue") {
        statusColour = const Color.fromARGB(255, 86, 0, 0);
      } else {
        statusColour = null; //uses default colour
      }
    } else {
      activeStatus = false;
    }}
    return [activeStatus, statusColour];
    }
    
    return FutureBuilder(
      future: getCardColour(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Icon(Icons.sms_failed);
        } else if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        } else {
          bool activeStatus = snapshot.data[0];
          Color? statusColour = snapshot.data[1];
          return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
            color: statusColour,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        i12hrTime,
                        style: const TextStyle(fontSize: 35),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end, //aligned to the right
                        children: [
                          Text(widget.details['instrument']),
                          Text(widget.status),
                          widget.details['students'].length == 1
                              ? Text(
                                  "${widget.details['students'].length} Student")
                              : Text(
                                  "${widget.details['students'].length} Students"),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5,),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    Expanded(flex: 2,child: SizedBox()),
Expanded(
  flex: 1,
  child: Text(
                      "Present",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Explained",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Absent",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  ],),
                  
                  for (int x = 0;
                      x <= widget.details['students'].length - 1;
                      x++) ...[
                    //for each student in the lesson
                        
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                widget.details['expand']['students'][x]['name'],
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                     
                    activeStatus
                        ? Expanded(
                          flex: 1,
                          child: Radio(
                              value: "Present",
                              groupValue: _rollOptions[x],
                              activeColor: Colors.green,
                              onChanged: (value) => setState(() {
                                    _rollOptions[x] = value!;
                                  })),
                        )
                        : const SizedBox(),
                    activeStatus
                        ? Expanded(
                          flex: 1,
                          child: Radio(
                              value: "Explained",
                              groupValue: _rollOptions[x],
                              activeColor: Colors.orange,
                              onChanged: (value) => setState(() {
                                    _rollOptions[x] = value!;
                                  })),
                        )
                        : const SizedBox(),
                    activeStatus
                        ? Expanded(
                          flex: 1,
                          child: Radio(
                              value: "Unexplained",
                              groupValue: _rollOptions[x],
                              activeColor: Colors.red,
                              onChanged: (value) => setState(() {
                                    _rollOptions[x] = value!;
                                  })),
                        )
                        : const SizedBox() ],
                    ),
                  ],
                  activeStatus
                      ? OutlinedButton(
                          style: ButtonStyle(
                              shadowColor: MaterialStateProperty.resolveWith(
                                  (states) => null)),
                          onPressed: () {
                            if (_rollOptions
                                .sublist(0, widget.details['students'].length)
                                .contains("none")) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                        title: const Text("Are you sure?"),
                                        content: const Text(
                                            "One or more students have no status. You can use this for cases where none of the three options completely fit. If you have already marked this lesson the old value will be overwritten with 'none'."),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Cancel")),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SubmittedPage(
                                                                lessonDetails:
                                                                    widget
                                                                        .details,
                                                                statuses:
                                                                    _rollOptions)),
                                                    (route) => false);
                                              },
                                              child: const Text("Confirm"))
                                        ],
                                      ));
                            } else {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SubmittedPage(
                                          lessonDetails: widget.details,
                                          statuses: _rollOptions)),
                                  (route) => false);
                            }
                          },
                          child: const Text("Submit"))
                      : const SizedBox(),
                ],
              ),
            )),
      ); }
      } ,
    );
  }
}