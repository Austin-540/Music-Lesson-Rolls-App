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
    _rollOptions = List.filled(widget.details['students'].length, "none");
  }

  @override
  Widget build(BuildContext context) {
    List studentNames = [];
    for (int x =0; x < widget.details['expand']['students'].length; x++) {
      studentNames.add(widget.details['expand']['students'][x]['name']);
    }

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

    Color? statusColour;
    bool activeStatus;
    DateTime now = DateTime.now();
      if (widget.details['weekday'] ==
          DateFormat('EEEE').format(now)) {
        activeStatus = true;
        if (widget.status == "Completed") {
          statusColour = Theme.of(context).colorScheme.tertiaryContainer;
        } else if (widget.status == "Overdue") {
          statusColour = Theme.of(context).colorScheme.errorContainer;
        } else {
          statusColour = null; //uses default colour
        }
      } else {
        activeStatus = false;
      }
    
    // return [activeStatus, statusColour];

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
                    widget.details['dont_send_email'] == true? 
                    const Text("*", style: TextStyle(fontSize: 35, color: Color.fromARGB(255, 223, 61, 61),),):const SizedBox(),

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
                const SizedBox(
                  height: 5,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(flex: 2, child: SizedBox()),
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
                  ],
                ),
                for (int x = 0;
                    x <= widget.details['students'].length - 1;
                    x++) ...[
                  //for each student in the lesson

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          widget.details['expand']['students'][x]['name'],
                          textAlign: TextAlign.center,
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
                          : const SizedBox()
                    ],
                  ),
                ],
                const SizedBox(
                  height: 10,
                ),
                activeStatus
                    ? OutlinedButton(
                        style: ButtonStyle(
                            shadowColor: MaterialStateProperty.resolveWith(
                                (states) => null)),
                        onPressed: () {
                          if (_rollOptions.isEmpty) {
                            showDialog(context: context, builder: (context) => AlertDialog(
                              title: const Text("You can't submit an empty lesson."),
                              content: const Text("Try going into the edit lessons page to add a student or delete this lesson."),
                              actions: [
                                TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("OK"))
                              ],
                            ));
                            return;
                          } 
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
                                                            sendEmail: !widget.details['dont_send_email'],
                                                            studentNames: studentNames,
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
                                      sendEmail: !widget.details['dont_send_email'],
                                      studentNames: studentNames,
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
    );
  }
}
