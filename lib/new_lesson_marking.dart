import 'package:intl/intl.dart';
import 'package:music_lessons_attendance/submitted_page.dart';

import 'package:flutter/material.dart';

class NewLessonInList extends StatefulWidget {
  final details;
  final status;
  const NewLessonInList({super.key, required this.details, required this.status});

  @override
  State<NewLessonInList> createState() => _NewLessonInListState();
}

class _NewLessonInListState extends State<NewLessonInList> {
 List _rollOptions = [];
  


 @override
 void initState() {
   super.initState();
   _rollOptions = List.filled(20, "none"); //makes max number of students in a lesson 20
 }


  @override
  Widget build(BuildContext context) {
    String? i12hrTime;

    //convert computer readable time into 12hr time for humans
  if (int.parse(widget.details['time'].substring(0,2)) > 12) {
      i12hrTime = "${int.parse(widget.details['time'].substring(0,2))-12}:${widget.details['time'].substring(2,4)} PM";
    } else {
      i12hrTime = "${widget.details['time'].substring(0,2)}:${widget.details['time'].substring(2,4)} AM"; 
    }

//get colour for the Card to be
    var statusColour;
    if (widget.details['weekday'] == DateFormat('EEEE').format(DateTime.now())){
    if (widget.status == "Completed") {
      statusColour = const Color.fromARGB(255, 214, 252, 205);
    } else if (widget.status == "Overdue") {
      statusColour = const Color.fromARGB(255, 255, 182, 182);
    } else {
      statusColour = null; //uses default colour
    }
    }
  
    
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
                  Text(i12hrTime
                  ,style: const TextStyle(fontSize: 35),),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end, //aligned to the right
                    children: [
                    Text(widget.details['instrument']),
                    Text(widget.status),
                    widget.details['students'].length == 1?
                      Text("${widget.details['students'].length} Student"):
                      Text("${widget.details['students'].length} Students"),],),
                ],
              ),
              const SizedBox(height: 10,),
              const Row(
                children: [
                  Spacer(),
                  Text("Present   Explained   Absent", style: TextStyle(fontSize: 10),),
                ],
              ),
              for (int x=0; x<= widget.details['students'].length-1; x++) ... [ //for each student in the lesson
                Row(
                  children: [
                    Text(widget.details['expand']['students'][x]['name']),
                    const Spacer(),
                    Radio(value: "Present", groupValue: _rollOptions[x], 
                    activeColor: Colors.green,
                    onChanged: (value) => setState(() {
                      _rollOptions[x] = value!;
                    })),
                    Radio(value: "Explained", groupValue: _rollOptions[x], 
                    activeColor: Colors.orange,
                    onChanged: (value) => setState(() {
                      _rollOptions[x] = value!;
                    })),
                    Radio(value: "Unexplained", groupValue: _rollOptions[x], 
                    activeColor: Colors.red,
                    onChanged: (value) => setState(() {
                      _rollOptions[x] = value!;
                    }))
                  ],
                )
              ],
              OutlinedButton(onPressed: () => 
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SubmittedPage(lessonDetails: widget.details, statuses: _rollOptions)), (route) => false),
                child: const Text("Submit"))
            ],
          ),
        )
        ),
    );
  }
}