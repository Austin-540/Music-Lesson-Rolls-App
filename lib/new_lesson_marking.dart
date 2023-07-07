import 'package:music_lessons_attendance/submitted_page.dart';

import 'globals.dart';
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
   _rollOptions = List.filled(widget.details['expand']['students'].length, "none");
 }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text("${widget.details['time'].toString().substring(0,2)}:${widget.details['time'].toString().substring(2,4)}"
                  ,style: TextStyle(fontSize: 35),),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                    Text(widget.details['instrument']),
                    Text(widget.status),
                    widget.details['students'].length == "1"?
                      Text("${widget.details['students'].length} Student"):
                      Text("${widget.details['students'].length} Students"),],),
                ],
              ),
              SizedBox(height: 10,),
              for (int x=0; x<= widget.details['students'].length-1; x++) ... [
                Row(
                  children: [
                    Text(widget.details['expand']['students'][x]['name']),
                    Spacer(),
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
              TextButton(onPressed: () => 
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => SubmittedPage(lessonDetails: widget.details, statuses: _rollOptions,))), 
                child: Text("Submit"))
            ],
          ),
        )
        ),
    );
  }
}