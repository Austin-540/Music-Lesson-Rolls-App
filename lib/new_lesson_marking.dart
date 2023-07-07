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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
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
        )
        ),
    );
  }
}